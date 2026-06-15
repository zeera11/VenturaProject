import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
  Headers,
  HttpException,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

const AUTH_SERVICE = 'http://localhost:3001';
const FINANCE_SERVICE = 'http://localhost:3002';
const TRAVEL_SERVICE = 'http://localhost:3003';

@Controller()
export class GatewayController {
  constructor(
    private httpService: HttpService,
  ) {}

  // ── AUTH ──────────────────────────────────────────────
  @Post('auth/login')
  async login(@Body() dto: any) {
    try {
      const res = await firstValueFrom(
        this.httpService.post(`${AUTH_SERVICE}/auth/login`, dto),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Post('auth/register')
  @UseInterceptors(
    FileInterceptor('profilePicture', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, callback) => {
          const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
          const ext = extname(file.originalname);
          callback(null, `${uniqueSuffix}${ext}`);
        },
      }),
    }),
  )
  async register(@UploadedFile() file: any, @Body() dto: any) {
    try {
      const payload = { ...dto };
      if (file) {
        payload.profilePicture = file.filename;
      }
      const res = await firstValueFrom(
        this.httpService.post(`${AUTH_SERVICE}/auth/register`, payload),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Post('auth/reset-password')
  async resetPassword(@Body() dto: any) {
    try {
      const res = await firstValueFrom(
        this.httpService.post(`${AUTH_SERVICE}/auth/reset-password`, dto),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Get('auth/profile')
  async getProfile(@Headers('authorization') authorization: string) {
    try {
      const res = await firstValueFrom(
        this.httpService.get(`${AUTH_SERVICE}/auth/profile`, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Put('auth/profile')
  @UseInterceptors(
    FileInterceptor('profilePicture', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, callback) => {
          const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
          const ext = extname(file.originalname);
          callback(null, `${uniqueSuffix}${ext}`);
        },
      }),
    }),
  )
  async updateProfile(
    @UploadedFile() file: any,
    @Body() dto: any,
    @Headers('authorization') authorization: string,
  ) {
    try {
      const payload = { ...dto };
      if (file) {
        payload.profilePicture = file.filename;
      }
      const res = await firstValueFrom(
        this.httpService.put(`${AUTH_SERVICE}/auth/profile`, payload, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  // ── FINANCE ───────────────────────────────────────────
  @Post('finance/expense')
  async addExpense(
    @Body() dto: any,
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.post(`${FINANCE_SERVICE}/finance/expense`, dto, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Put('finance/expense/:id')
  async updateExpense(
    @Param('id') id: string,
    @Body() dto: any,
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.put(`${FINANCE_SERVICE}/finance/expense/${id}`, dto, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Delete('finance/expense/:id')
  async deleteExpense(
    @Param('id') id: string,
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.delete(`${FINANCE_SERVICE}/finance/expense/${id}`, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Delete('finance/expenses/all')
  async clearExpenses(@Headers('authorization') authorization: string) {
    try {
      const res = await firstValueFrom(
        this.httpService.delete(`${FINANCE_SERVICE}/finance/expenses/all`, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Post('finance/budget')
  async addBudget(
    @Body() dto: any,
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.post(`${FINANCE_SERVICE}/finance/budget`, dto, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Get('finance')
  async getFinance(
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.get(`${FINANCE_SERVICE}/finance`, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Get('finance/summary')
  async getFinanceSummary(
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.get(`${FINANCE_SERVICE}/finance/summary`, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  // ── TRAVEL ────────────────────────────────────────────
  @Get('travel/destinations')
  async getDestinations() {
    try {
      const res = await firstValueFrom(
        this.httpService.get(`${TRAVEL_SERVICE}/recommendation/destinations`),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Get('travel/itinerary')
  async getItinerary(
    @Query('city') city: string,
    @Query('days') days: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.get(
          `${TRAVEL_SERVICE}/recommendation/itinerary?city=${city}&days=${days}`,
        ),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Post('travel/recommendation')
  async recommendation(
    @Body() dto: any,
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.post(
          `${TRAVEL_SERVICE}/recommendation`,
          dto,
          {
            headers: { Authorization: authorization },
          },
        ),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Post('travel/itinerary')
  async saveItinerary(
    @Body() dto: any,
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.post(`${TRAVEL_SERVICE}/recommendation/itinerary/save`, dto, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Get('travel/itinerary/list')
  async listItineraries(@Headers('authorization') authorization: string) {
    try {
      const res = await firstValueFrom(
        this.httpService.get(`${TRAVEL_SERVICE}/recommendation/itinerary/list`, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Put('travel/itinerary/:id')
  async updateItinerary(
    @Param('id') id: string,
    @Body() dto: any,
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.put(`${TRAVEL_SERVICE}/recommendation/itinerary/${id}`, dto, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Delete('travel/itinerary/:id')
  async deleteItinerary(
    @Param('id') id: string,
    @Headers('authorization') authorization: string,
  ) {
    try {
      const res = await firstValueFrom(
        this.httpService.delete(`${TRAVEL_SERVICE}/recommendation/itinerary/${id}`, {
          headers: { Authorization: authorization },
        }),
      );
      return res.data;
    } catch (error) {
      throw new HttpException(
        error.response?.data || 'Internal Server Error',
        error.response?.status || 500,
      );
    }
  }

  @Post('travel/upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, callback) => {
          const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
          const ext = extname(file.originalname);
          callback(null, `dest-${uniqueSuffix}${ext}`);
        },
      }),
    }),
  )
  uploadFile(@UploadedFile() file: any) {
    if (!file) {
      throw new HttpException('File upload failed', 400);
    }
    return {
      filename: file.filename,
    };
  }
}