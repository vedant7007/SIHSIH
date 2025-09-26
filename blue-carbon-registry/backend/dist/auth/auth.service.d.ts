import { PrismaService } from '../prisma/prisma.service';
export declare class AuthService {
    private prisma;
    constructor(prisma: PrismaService);
    login(loginDto: any): Promise<{
        access_token: string;
        user: {
            id: string;
            email: any;
            role: string;
        };
    }>;
}
