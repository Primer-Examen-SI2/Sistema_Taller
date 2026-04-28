import { Injectable, signal, computed } from '@angular/core';
import { Workshop, Technician, Incident, ServiceHistory, IncidentType, PriorityLevel, ServiceStatus } from '../models/incident.model';

@Injectable({ providedIn: 'root' })
export class DataService {
  private _workshops = signal<Workshop[]>(this.getStaticWorkshops());
  private _incidents = signal<Incident[]>(this.getStaticIncidents());
  private _history = signal<ServiceHistory[]>(this.getStaticHistory());

  workshops = computed(() => this._workshops());
  incidents = computed(() => this._incidents());
  history = computed(() => this._history());

  private getStaticWorkshops(): Workshop[] {
    return [
      {
        id: 'w1',
        name: 'AutoFix Pro',
        email: 'autofix@taller.com',
        password: '123456',
        phone: '+51 987 654 321',
        address: 'Av. Arequipa 1234, Lima',
        location: { lat: -12.0464, lng: -77.0428, address: 'Av. Arequipa 1234, Lima' },
        specialties: ['mechanical', 'battery', 'overheating'],
        technicians: [
          { id: 't1', name: 'Carlos Mendoza', specialty: ['mechanical', 'overheating'], isAvailable: true, currentLocation: { lat: -12.05, lng: -77.04, address: 'Centro de Lima' }, activeAssignments: 0 },
          { id: 't2', name: 'María García', specialty: ['battery', 'mechanical'], isAvailable: true, currentLocation: { lat: -12.06, lng: -77.03, address: 'Miraflores' }, activeAssignments: 1 },
          { id: 't3', name: 'Jorge Ramírez', specialty: ['mechanical', 'tire'], isAvailable: false, currentLocation: { lat: -12.07, lng: -77.02, address: 'San Isidro' }, activeAssignments: 2 },
        ],
        commissionRate: 0.10,
        isActive: true,
      },
      {
        id: 'w2',
        name: 'Mecánica del Sur',
        email: 'sur@taller.com',
        password: '123456',
        phone: '+51 912 345 678',
        address: 'Av. Colonial 567, Lima',
        location: { lat: -12.05, lng: -77.05, address: 'Av. Colonial 567, Lima' },
        specialties: ['tire', 'lockout', 'accident'],
        technicians: [
          { id: 't4', name: 'Ana Torres', specialty: ['tire', 'lockout'], isAvailable: true, currentLocation: { lat: -12.04, lng: -77.06, address: 'Barranco' }, activeAssignments: 0 },
          { id: 't5', name: 'Luis Paredes', specialty: ['accident', 'tire'], isAvailable: true, currentLocation: { lat: -12.03, lng: -77.05, address: 'Surquillo' }, activeAssignments: 1 },
        ],
        commissionRate: 0.10,
        isActive: true,
      },
    ];
  }

  private getStaticIncidents(): Incident[] {
    return [
      {
        id: 'inc1',
        userId: 'u1',
        userName: 'Roberto Sánchez',
        type: 'mechanical',
        description: 'El motor se apagó de repente en la carretera. Humo saliendo del capó.',
        audioTranscription: 'Mi carro se apagó de repente, hay humo saliendo del capó, necesito ayuda urgente.',
        imageUrl: 'assets/incident1.jpg',
        location: { lat: -12.04, lng: -77.03, address: 'Panamericana Sur Km 15, Lima' },
        priority: 'critical',
        status: 'pending',
        aiSummary: 'Falla mecánica severa con indicio de sobrecalentamiento. Motor apagado con emisión de humo. Se recomienda atención inmediata.',
        aiClassification: 'Falla de motor / Sobrecalentamiento',
        aiConfidence: 0.92,
        createdAt: new Date('2026-04-27T14:30:00'),
        estimatedCost: 350,
      },
      {
        id: 'inc2',
        userId: 'u2',
        userName: 'Laura Vargas',
        type: 'tire',
        description: 'Llanta delantera derecha pinchada. Estoy en el estacionamiento del centro comercial.',
        location: { lat: -12.06, lng: -77.04, address: 'CC Plaza Lima, San Miguel' },
        priority: 'medium',
        status: 'pending',
        aiSummary: 'Pinchazo de llanta delantera derecha en estacionamiento. Ubicación segura. Prioridad media.',
        aiClassification: 'Pinchazo de llanta',
        aiConfidence: 0.97,
        createdAt: new Date('2026-04-27T15:10:00'),
        estimatedCost: 80,
      },
      {
        id: 'inc3',
        userId: 'u3',
        userName: 'Pedro Limaylla',
        type: 'battery',
        description: 'El carro no arranca. Batería muerta. Necesito un puente.',
        audioTranscription: 'No arranca mi carro, creo que es la batería, necesito un puente por favor.',
        location: { lat: -12.05, lng: -77.02, address: 'Jr. Cusco 456, Cercado de Lima' },
        priority: 'high',
        status: 'pending',
        aiSummary: 'Batería descargada. Vehículo no arranca. Requiere puente o reemplazo de batería.',
        aiClassification: 'Batería descargada',
        aiConfidence: 0.95,
        createdAt: new Date('2026-04-27T16:00:00'),
        estimatedCost: 120,
      },
      {
        id: 'inc4',
        userId: 'u4',
        userName: 'Carmen Flores',
        type: 'lockout',
        description: 'Dejé las llaves dentro del carro. Las puertas se bloquearon automáticamente.',
        location: { lat: -12.03, lng: -77.01, address: 'Av. Javier Prado, San Isidro' },
        priority: 'low',
        status: 'pending',
        aiSummary: 'Llaves bloqueadas dentro del vehículo. Cerraduras automáticas. Sin daño al vehículo.',
        aiClassification: 'Bloqueo de llaves',
        aiConfidence: 0.98,
        createdAt: new Date('2026-04-27T16:45:00'),
        estimatedCost: 60,
      },
      {
        id: 'inc5',
        userId: 'u5',
        userName: 'Miguel Ángel Rojas',
        type: 'accident',
        description: 'Choque leve en intersección. Daño en parachoques delantero. No hay heridos.',
        imageUrl: 'assets/incident5.jpg',
        location: { lat: -12.07, lng: -77.05, address: 'Av. Brasil con Av. Aramburú, Lima' },
        priority: 'high',
        status: 'pending',
        aiSummary: 'Accidente leve en intersección. Daño en parachoques delantero. Sin heridos reportados. Se requiere grúa y evaluación.',
        aiClassification: 'Accidente leve / Daño en parachoques',
        aiConfidence: 0.88,
        createdAt: new Date('2026-04-27T17:20:00'),
        estimatedCost: 250,
      },
      {
        id: 'inc6',
        userId: 'u6',
        userName: 'Sofía Delgado',
        type: 'overheating',
        description: 'El indicador de temperatura está al máximo. Tuve que detenerme en la berma.',
        audioTranscription: 'El carro se está calentando mucho, tuve que parar, el indicador está al máximo.',
        location: { lat: -12.08, lng: -77.06, address: 'Panamericana Norte Km 8, Lima' },
        priority: 'critical',
        status: 'accepted',
        aiSummary: 'Sobrecalentamiento crítico del motor. Vehículo detenido en berma. Riesgo de daño al motor si no se atiende pronto.',
        aiClassification: 'Sobrecalentamiento crítico',
        aiConfidence: 0.91,
        createdAt: new Date('2026-04-27T18:00:00'),
        workshopId: 'w1',
        assignedTechnician: 't1',
        estimatedCost: 200,
      },
    ];
  }

  private getStaticHistory(): ServiceHistory[] {
    return [
      { id: 'h1', incidentId: 'inc_h1', technicianId: 't1', technicianName: 'Carlos Mendoza', clientName: 'Juan Pérez', incidentType: 'mechanical', priority: 'high', status: 'completed', cost: 300, commission: 30, completedAt: new Date('2026-04-25T18:00:00'), createdAt: new Date('2026-04-25T14:00:00') },
      { id: 'h2', incidentId: 'inc_h2', technicianId: 't2', technicianName: 'María García', clientName: 'Ana Quispe', incidentType: 'battery', priority: 'medium', status: 'completed', cost: 150, commission: 15, completedAt: new Date('2026-04-24T16:30:00'), createdAt: new Date('2026-04-24T12:00:00') },
      { id: 'h3', incidentId: 'inc_h3', technicianId: 't3', technicianName: 'Jorge Ramírez', clientName: 'Luis Soto', incidentType: 'tire', priority: 'low', status: 'completed', cost: 80, commission: 8, completedAt: new Date('2026-04-23T20:00:00'), createdAt: new Date('2026-04-23T17:00:00') },
      { id: 'h4', incidentId: 'inc_h4', technicianId: 't1', technicianName: 'Carlos Mendoza', clientName: 'Rosa Mendoza', incidentType: 'overheating', priority: 'critical', status: 'completed', cost: 450, commission: 45, completedAt: new Date('2026-04-22T19:00:00'), createdAt: new Date('2026-04-22T15:00:00') },
      { id: 'h5', incidentId: 'inc_h5', technicianId: 't4', technicianName: 'Ana Torres', clientName: 'Diego Huamán', incidentType: 'lockout', priority: 'low', status: 'completed', cost: 60, commission: 6, completedAt: new Date('2026-04-21T14:00:00'), createdAt: new Date('2026-04-21T12:30:00') },
    ];
  }

  getIncidentsForWorkshop(workshopId: string): Incident[] {
    return this._incidents().filter(i => i.status === 'pending' || i.workshopId === workshopId);
  }

  getAvailableIncidents(): Incident[] {
    return this._incidents().filter(i => i.status === 'pending');
  }

  getAcceptedIncidents(workshopId: string): Incident[] {
    return this._incidents().filter(i => i.workshopId === workshopId && (i.status === 'accepted' || i.status === 'in_progress'));
  }

  acceptIncident(incidentId: string, workshopId: string, technicianId: string): void {
    this._incidents.update(incidents =>
      incidents.map(i => i.id === incidentId ? { ...i, status: 'accepted' as ServiceStatus, workshopId, assignedTechnician: technicianId } : i)
    );
  }

  rejectIncident(incidentId: string): void {
    this._incidents.update(incidents =>
      incidents.map(i => i.id === incidentId ? { ...i, status: 'rejected' as ServiceStatus } : i)
    );
  }

  updateIncidentStatus(incidentId: string, status: ServiceStatus): void {
    this._incidents.update(incidents =>
      incidents.map(i => i.id === incidentId ? { ...i, status } : i)
    );
  }

  toggleTechnicianAvailability(technicianId: string): void {
    this._workshops.update(workshops =>
      workshops.map(w => ({
        ...w,
        technicians: w.technicians.map(t =>
          t.id === technicianId ? { ...t, isAvailable: !t.isAvailable } : t
        ),
      }))
    );
  }

  addWorkshop(workshop: Workshop): void {
    this._workshops.update(ws => [...ws, workshop]);
  }

  getWorkshopById(id: string): Workshop | undefined {
    return this._workshops().find(w => w.id === id);
  }

  getHistoryForWorkshop(workshopId: string): ServiceHistory[] {
    return this._history().filter(h => this._workshops().find(w => w.id === workshopId)?.technicians.some(t => t.id === h.technicianId));
  }

  getIncidentById(id: string): Incident | undefined {
    return this._incidents().find(i => i.id === id);
  }

  getTechnicianById(workshopId: string, techId: string): Technician | undefined {
    const ws = this._workshops().find(w => w.id === workshopId);
    return ws?.technicians.find(t => t.id === techId);
  }

  addTechnician(workshopId: string, technician: Technician): void {
    this._workshops.update(workshops =>
      workshops.map(w => w.id === workshopId ? { ...w, technicians: [...w.technicians, technician] } : w)
    );
  }

  updateTechnician(workshopId: string, technician: Technician): void {
    this._workshops.update(workshops =>
      workshops.map(w => w.id === workshopId ? {
        ...w,
        technicians: w.technicians.map(t => t.id === technician.id ? technician : t)
      } : w)
    );
  }

  deleteTechnician(workshopId: string, technicianId: string): void {
    this._workshops.update(workshops =>
      workshops.map(w => w.id === workshopId ? {
        ...w,
        technicians: w.technicians.filter(t => t.id !== technicianId)
      } : w)
    );
  }
}
