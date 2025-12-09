export interface Task {
  id: string
  tenant_id: string
  related_id: string  // application_id
  title: string
  description: string | null
  type: 'call' | 'email' | 'review'
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled'
  assigned_to: string | null
  due_at: string
  completed_at: string | null
  created_at: string
  updated_at: string
}

