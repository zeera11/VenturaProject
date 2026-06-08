import { IsNumber, IsObject, IsString, Min } from 'class-validator';

export class SaveItineraryDto {
  @IsString()
  city: string;

  @IsNumber()
  @Min(1)
  days: number;

  @IsString()
  itineraryType: string;

  @IsObject()
  itinerary: any;
}
