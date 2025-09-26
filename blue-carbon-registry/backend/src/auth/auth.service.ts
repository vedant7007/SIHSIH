import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}

  async login(loginDto: any) {
    // Demo login implementation
    return {
      access_token: 'demo-token',
      user: {
        id: '1',
        email: loginDto.email,
        role: 'NGO',
      },
    };
  }
}