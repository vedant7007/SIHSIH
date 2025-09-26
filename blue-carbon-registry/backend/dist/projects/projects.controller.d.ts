import { ProjectsService } from './projects.service';
export declare class ProjectsController {
    private readonly projectsService;
    constructor(projectsService: ProjectsService);
    findAll(): Promise<{
        projects: any[];
        message: string;
    }>;
    create(createProjectDto: any): Promise<any>;
}
