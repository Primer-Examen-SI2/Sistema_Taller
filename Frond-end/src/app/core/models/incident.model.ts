export type IncidentType = 'mechanical' | 'tire' | 'battery' | 'overheating' | 'accident' | 'lockout' | 'other';
export type PriorityLevel = 'critical' | 'high' | 'medium' | 'low';
export type ServiceStatus = 'pending' | 'accepted' | 'in_progress' | 'completed' | 'rejected';

export interface Location {
  lat: number;
  lng: number;
  address: string;
}

export interface Incident {
  id: string;
  userId: string;
  userName: string;
  type: IncidentType;
  description: string;
  audioTranscription?: string;
  imageUrl?: string;
  location: Location;
  priority: PriorityLevel;
  status: ServiceStatus;
  aiSummary: string;
  aiClassification: string;
  aiConfidence: number;
  createdAt: Date;
  assignedTechnician?: string;
  workshopId?: string;
  estimatedCost?: number;
}

export interface Technician {
  id: string;
  name: string;
  specialty: IncidentType[];
  isAvailable: boolean;
  currentLocation: Location;
  activeAssignments: number;
}

export interface Workshop {
  id: string;
  name: string;
  email: string;
  password: string;
  phone: string;
  address: string;
  location: Location;
  specialties: IncidentType[];
  technicians: Technician[];
  commissionRate: number;
  isActive: boolean;
}

export interface ServiceHistory {
  id: string;
  incidentId: string;
  technicianId: string;
  technicianName: string;
  clientName: string;
  incidentType: IncidentType;
  priority: PriorityLevel;
  status: ServiceStatus;
  cost: number;
  commission: number;
  completedAt: Date;
  createdAt: Date;
}
