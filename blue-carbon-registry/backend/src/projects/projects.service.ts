import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ProjectsService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return {
      projects: [],
      message: 'Projects retrieved successfully',
    };
  }

  async create(createProjectDto: any) {
    return {
      id: '1',
      ...createProjectDto,
      status: 'DRAFT',
      createdAt: new Date(),
    };
  }
}