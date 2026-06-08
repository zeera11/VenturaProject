import { IsNumber, Min } from 'class-validator';

export class CreateBudgetDto {
  @IsNumber()
  @Min(0)
  totalBudget: number;
}
