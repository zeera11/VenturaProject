import { Injectable } from '@nestjs/common';
import { ItineraryGenerator } from './itinerary.generator';

const itineraryGen = new ItineraryGenerator();

@Injectable()
export class RecommendationEngine {
  process(dto, destinations) {
    const dest = destinations[0];

    const dailyBudget = dto.budget / dto.days;
    const round = (n: number) => Math.round(n);

    const budgetPlan = {
      food: round(dailyBudget * 0.3),
      transport: round(dailyBudget * 0.2),
      attraction: round(dailyBudget * 0.3),
      accommodation: round(dailyBudget * 0.15),
      misc: round(dailyBudget * 0.05),
    };

    const tripType =
      dto.days <= 3
        ? 'Compact Trip'
        : dto.days <= 5
        ? 'Balanced Trip'
        : 'Slow & Explore Trip';

    let score = 0;

    if (dto.categories && dto.categories.some((c) => dest.categories.includes(c))) {
      score += 40;
    }

    if (dest.estimatedDailyBudget <= dailyBudget) {
      score += 30;
    }

    if (dest.city.toLowerCase().includes(dto.city.toLowerCase())) {
      score += 30;
    }

    const itineraryResult = itineraryGen.generate(dest.city, dto.days);

    return {
      ...dest,
      score,
      dailyBudget,
      budgetPlan,
      itineraryType: tripType,
      itinerary: itineraryResult,
      explanation: `${tripType} – best match for ${(dto.categories || []).join(', ')} travel style`,
    };
  }
}