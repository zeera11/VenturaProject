import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';

import { FinanceService } from './finance.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { CreateBudgetDto } from './dto/create-budget.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

@Controller('finance')
export class FinanceController {
  constructor(
    private financeService: FinanceService,
  ) {}

  @UseGuards(JwtAuthGuard)
  @Post('expense')
  addExpense(
    @Body() dto: CreateExpenseDto,
    @Req() req: any,
  ) {
    return this.financeService.addExpense(dto, req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Put('expense/:id')
  updateExpense(
    @Param('id') id: string,
    @Body() dto: UpdateExpenseDto,
    @Req() req: any,
  ) {
    return this.financeService.updateExpense(id, dto, req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Delete('expense/:id')
  deleteExpense(
    @Param('id') id: string,
    @Req() req: any,
  ) {
    return this.financeService.deleteExpense(id, req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Delete('expenses/all')
  clearExpenses(@Req() req: any) {
    return this.financeService.clearExpenses(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Post('budget')
  addBudget(
    @Body() dto: CreateBudgetDto,
    @Req() req: any,
  ) {
    return this.financeService.addBudget(dto, req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  getFinance(@Req() req: any) {
    return this.financeService.getAll(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('summary')
  getSummary(@Req() req: any) {
    return this.financeService.getSummary(req.user.userId);
  }
}