import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { FinanceController } from './finance.controller';
import { FinanceService } from './finance.service';
import { JwtStrategy } from '../auth/jwt.strategy';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
  ],
  controllers: [FinanceController],
  providers: [
    FinanceService,
    JwtStrategy,
    JwtAuthGuard,
  ],
})
export class FinanceModule {}
