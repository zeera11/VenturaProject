import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TravelModule } from './travel/travel.module';
import { RecommendationModule } from './recommendation/recommendation.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TravelModule,
    RecommendationModule,
  ],
})
export class AppModule {}
