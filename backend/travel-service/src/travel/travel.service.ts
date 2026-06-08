import { Injectable } from '@nestjs/common';

@Injectable()
export class TravelService {
  private destinations = [
    {
      country: 'Japan',
      region: 'Asia',
      city: 'Tokyo',
      categories: ['culture', 'shopping', 'entertainment'],
      estimatedDailyBudget: 1200000,
    },
    {
      country: 'Indonesia',
      region: 'Asia',
      city: 'Bandung',
      categories: ['food', 'nature', 'instagrammable'],
      estimatedDailyBudget: 500000,
    },
  ];

  getDestinations(country: string, city?: string) {
    return this.destinations.filter((d) => {
      const matchCountry = d.country.toLowerCase().includes(country.toLowerCase());
      const matchCity = city ? d.city.toLowerCase().includes(city.toLowerCase()) : true;
      return matchCountry && matchCity;
    });
  }
}
