import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';

import { RecommendationEngine } from './recommendation.engine';
import { db } from '../config/firebase.config';

@Injectable()
export class RecommendationService {
  constructor(
    private engine: RecommendationEngine,
  ) {}

  // Database destinasi yang tersedia
  private destinations = [
    {
      city: 'Jakarta',
      categories: ['shopping', 'food', 'culture', 'entertainment'],
      estimatedDailyBudget: 750000,
      description: 'Ibu kota Indonesia dengan segudang destinasi wisata budaya, kuliner, dan hiburan.',
      image: 'jakarta',
    },
    {
      city: 'Bandung',
      categories: ['food', 'nature', 'shopping', 'relaxation'],
      estimatedDailyBudget: 500000,
      description: 'Kota kembang dengan udara sejuk, kuliner lezat, dan wisata alam yang memukau.',
      image: 'bandung',
    },
    {
      city: 'Yogyakarta',
      categories: ['culture', 'food', 'nature', 'relaxation'],
      estimatedDailyBudget: 450000,
      description: 'Kota budaya Jawa dengan candi-candi megah, seni batik, dan kuliner gudeg.',
      image: 'yogyakarta',
    },
    {
      city: 'Bali',
      categories: ['nature', 'beach', 'culture', 'relaxation', 'adventure'],
      estimatedDailyBudget: 1200000,
      description: 'Pulau Dewata dengan pantai eksotis, pura sakral, dan budaya Bali yang kaya.',
      image: 'bali',
    },
    {
      city: 'Labuan Bajo',
      categories: ['adventure', 'nature', 'beach'],
      estimatedDailyBudget: 1500000,
      description: 'Surga tersembunyi di NTT dengan Komodo, Pink Beach, dan snorkeling kelas dunia.',
      image: 'labuanbajo',
    },
    {
      city: 'Lombok',
      categories: ['beach', 'nature', 'relaxation', 'adventure'],
      estimatedDailyBudget: 850000,
      description: 'Pulau indah dengan Rinjani, Gili Islands, dan pantai-pantai yang masih alami.',
      image: 'lombok',
    },
    {
      city: 'Sumba',
      categories: ['culture', 'nature', 'beach'],
      estimatedDailyBudget: 800000,
      description: 'Perpaduan sempurna antara budaya unik, sabana luas, dan pantai yang indah.',
      image: 'sumba',
    },
    {
      city: 'Raja Ampat',
      categories: ['nature', 'beach', 'adventure'],
      estimatedDailyBudget: 1800000,
      description: 'Kepulauan eksotis di Papua Barat, surga bawah laut terbaik di dunia.',
      image: 'rajaampat',
    },
  ];

  // Dapatkan semua destinasi
  getAllDestinations() {
    return this.destinations;
  }

  // Generate itinerary langsung tanpa rekomendasi
  getItinerary(city: string, days: number) {
    const { ItineraryGenerator } = require('./itinerary.generator');
    const gen = new ItineraryGenerator();
    return gen.generate(city, days);
  }

  generate(dto) {
    const destination = this.destinations.find(
      (d) =>
        d.city.toLowerCase() ===
        dto.city.toLowerCase(),
    );

    if (!destination) {
      throw new NotFoundException(
        `Destination '${dto.city}' not found. Available: ${this.destinations.map(d => d.city).join(', ')}`,
      );
    }

    return this.engine.process(
      dto,
      [destination],
    );
  }

  // ── ITINERARY CRUD METHODS ───────────────────────────

  async saveItinerary(dto: any, userId: string) {
    const docRef = await db.collection('itineraries').add({
      ...dto,
      userId,
      createdAt: new Date().toISOString(),
    });
    return {
      message: 'Itinerary saved successfully',
      id: docRef.id,
    };
  }

  async listItineraries(userId: string) {
    const snapshot = await db
      .collection('itineraries')
      .where('userId', '==', userId)
      .get();
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));
  }

  async updateItinerary(id: string, dto: any, userId: string) {
    const docRef = db.collection('itineraries').doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException('Itinerary not found');
    }
    const data = doc.data();
    if (data?.userId !== userId) {
      throw new UnauthorizedException('Unauthorized to update this itinerary');
    }
    await docRef.update({
      city: dto.city,
      days: dto.days,
      itineraryType: dto.itineraryType,
      itinerary: dto.itinerary,
      updatedAt: new Date().toISOString(),
    });
    return {
      message: 'Itinerary updated successfully',
      id,
    };
  }

  async deleteItinerary(id: string, userId: string) {
    const docRef = db.collection('itineraries').doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      throw new NotFoundException('Itinerary not found');
    }
    const data = doc.data();
    if (data?.userId !== userId) {
      throw new UnauthorizedException('Unauthorized to delete this itinerary');
    }
    await docRef.delete();
    return {
      message: 'Itinerary deleted successfully',
      id,
    };
  }
}