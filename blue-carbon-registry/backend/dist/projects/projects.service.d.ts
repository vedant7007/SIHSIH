import { PrismaService } from '../prisma/prisma.service';
export declare class ProjectsService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(): Promise<{
        projects: any[];
        message: string;
    }>;
    create(createProjectDto: any): Promise<any>;
}
