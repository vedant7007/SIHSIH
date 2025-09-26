import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): object {
    return {
      name: 'Blue Carbon Registry API',
      version: '1.0.0',
      description: 'SIH 25038 Blue Carbon Registry & MRV System',
      status: 'running',
      timestamp: new Date().toISOString(),
    };
  }

  getHealth(): object {
    return {
      status: 'ok',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      memory: process.memoryUsage(),
    };
  }
}