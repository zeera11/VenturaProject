import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { FinanceModule } from './finance/finance.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    FinanceModule,
  ],
})
export class AppModule {}
