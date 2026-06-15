import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { db } from '../config/firebase.config';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class AuthService {
  constructor(private jwtService: JwtService) {}

  async register(dto: RegisterDto) {
    if (dto.email && dto.email.toLowerCase().includes('gamil.com')) {
      throw new BadRequestException('Invalid email domain: gamil.com is not allowed. Did you mean gmail.com?');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);
    const userData = {
      email: dto.email,
      username: dto.username,
      password: hashedPassword,
      phoneNumber: '',
      profilePicture: dto.profilePicture || '',
    };

    const existing = await db
      .collection('users')
      .where('email', '==', dto.email)
      .get();

    if (!existing.empty) {
      throw new BadRequestException('Email already registered');
    }

    await db.collection('users').add(userData);
    return {
      message: 'Register success',
      data: {
        email: dto.email,
        username: dto.username,
      },
    };
  }

  async login(dto: LoginDto) {
    const snapshot = await db
      .collection('users')
      .where('email', '==', dto.email)
      .get();

    if (snapshot.empty) {
      throw new NotFoundException('User not found');
    }

    const userDoc = snapshot.docs[0];
    const user = userDoc.data();
    const isPasswordValid = await bcrypt.compare(dto.password, user.password);

    if (!isPasswordValid) {
      throw new BadRequestException('Invalid credentials');
    }

    const payload = {
      sub: userDoc.id,
      email: user.email,
    };

    const token = await this.jwtService.signAsync(payload);
    return {
      message: 'Login success',
      access_token: token,
    };
  }

  async getProfile(userId: string) {
    const doc = await db.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw new NotFoundException('User not found');
    }
    const data = doc.data();
    return {
      userId: doc.id,
      username: data.username,
      email: data.email,
      phoneNumber: data.phoneNumber || '',
      profilePicture: data.profilePicture || '',
    };
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const docRef = db.collection('users').doc(userId);
    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException('User not found');
    }

    const updateData: any = {};
    if (dto.username !== undefined) updateData.username = dto.username;
    if (dto.email !== undefined) updateData.email = dto.email;
    if (dto.phoneNumber !== undefined) updateData.phoneNumber = dto.phoneNumber;
    if (dto.profilePicture !== undefined) updateData.profilePicture = dto.profilePicture;

    await docRef.update(updateData);
    const updated = await docRef.get();
    const updatedData = updated.data();
    return {
      message: 'Profile updated successfully',
      data: {
        userId,
        username: updatedData.username,
        email: updatedData.email,
        phoneNumber: updatedData.phoneNumber || '',
        profilePicture: updatedData.profilePicture || '',
      },
    };
  }

  async resetPassword(email: string, newPassword: string) {
    const snapshot = await db
      .collection('users')
      .where('email', '==', email)
      .get();

    if (snapshot.empty) {
      throw new NotFoundException('User with this email not found');
    }

    const userDoc = snapshot.docs[0];
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await userDoc.ref.update({ password: hashedPassword });

    return {
      message: 'Password updated successfully',
    };
  }
}
