import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { RecommendationController } from './recommendation.controller';
import { RecommendationService } from './recommendation.service';
import { RecommendationEngine } from './recommendation.engine';
import { JwtStrategy } from '../auth/jwt.strategy';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
  ],
  controllers: [RecommendationController],
  providers: [
    RecommendationService,
    RecommendationEngine,
    JwtStrategy,
    JwtAuthGuard,
  ],
})
export class RecommendationModule {}
