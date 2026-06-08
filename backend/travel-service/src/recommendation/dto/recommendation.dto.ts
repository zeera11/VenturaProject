import { IsArray, IsNumber, IsString, Min } from 'class-validator';

export class RecommendationDto {
  @IsString()
  city: string;

  @IsArray()
  @IsString({ each: true })
  categories: string[];

  @IsString()
  activityLevel: string;

  @IsNumber()
  @Min(1)
  days: number;

  @IsNumber()
  @Min(0)
  budget: number;
}
