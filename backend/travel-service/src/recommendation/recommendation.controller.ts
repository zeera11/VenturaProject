import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';

import { RecommendationService } from './recommendation.service';
import { RecommendationDto } from './dto/recommendation.dto';
import { SaveItineraryDto } from './dto/save-itinerary.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('recommendation')
export class RecommendationController {
  constructor(
    private service: RecommendationService,
  ) {}

  // GET /recommendation/destinations – daftar semua destinasi
  @Get('destinations')
  getDestinations() {
    return this.service.getAllDestinations();
  }

  // GET /recommendation/itinerary?city=Bali&days=3
  @Get('itinerary')
  getItinerary(
    @Query('city') city: string,
    @Query('days') days: string,
  ) {
    return this.service.getItinerary(city, parseInt(days) || 3);
  }

  // POST /recommendation – generate full recommendation + itinerary
  @Post()
  generate(
    @Body()
    dto: RecommendationDto,
  ) {
    return this.service.generate(dto);
  }

  // ── ITINERARY CRUD ────────────────────────────────────

  @UseGuards(JwtAuthGuard)
  @Post('itinerary/save')
  saveItinerary(@Body() dto: SaveItineraryDto, @Req() req: any) {
    return this.service.saveItinerary(dto, req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('itinerary/list')
  listItineraries(@Req() req: any) {
    return this.service.listItineraries(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Put('itinerary/:id')
  updateItinerary(@Param('id') id: string, @Body() dto: SaveItineraryDto, @Req() req: any) {
    return this.service.updateItinerary(id, dto, req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Delete('itinerary/:id')
  deleteItinerary(@Param('id') id: string, @Req() req: any) {
    return this.service.deleteItinerary(id, req.user.userId);
  }
}