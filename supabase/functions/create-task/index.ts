import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface CreateTaskRequest {
  application_id: string
  task_type: 'call' | 'email' | 'review'
  due_at: string
  title?: string
  description?: string
}

interface CreateTaskResponse {
  success: boolean
  task_id?: string
  error?: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse request body
    const body: CreateTaskRequest = await req.json()
    const { application_id, task_type, due_at, title, description } = body

    // Validate required fields
    if (!application_id) {
      return new Response(
        JSON.stringify({ success: false, error: 'application_id is required' } as CreateTaskResponse),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Validate UUID format
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
    if (!uuidRegex.test(application_id)) {
      return new Response(
        JSON.stringify({ success: false, error: 'application_id must be a valid UUID' } as CreateTaskResponse),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Validate task_type
    const validTaskTypes = ['call', 'email', 'review']
    if (!task_type || !validTaskTypes.includes(task_type)) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `task_type must be one of: ${validTaskTypes.join(', ')}` 
        } as CreateTaskResponse),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Validate due_at
    if (!due_at) {
      return new Response(
        JSON.stringify({ success: false, error: 'due_at is required' } as CreateTaskResponse),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Parse and validate due_at is a valid date and in the future
    const dueDate = new Date(due_at)
    if (isNaN(dueDate.getTime())) {
      return new Response(
        JSON.stringify({ success: false, error: 'due_at must be a valid ISO 8601 date string' } as CreateTaskResponse),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const now = new Date()
    if (dueDate <= now) {
      return new Response(
        JSON.stringify({ success: false, error: 'due_at must be in the future' } as CreateTaskResponse),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Initialize Supabase client with service role
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ success: false, error: 'Server configuration error' } as CreateTaskResponse),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Verify application exists
    const { data: application, error: appError } = await supabase
      .from('applications')
      .select('id, tenant_id')
      .eq('id', application_id)
      .single()

    if (appError || !application) {
      return new Response(
        JSON.stringify({ success: false, error: 'Application not found' } as CreateTaskResponse),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Generate default title if not provided
    const taskTitle = title || `${task_type.charAt(0).toUpperCase() + task_type.slice(1)} task for application`

    // Insert task
    const { data: newTask, error: insertError } = await supabase
      .from('tasks')
      .insert({
        tenant_id: application.tenant_id,
        related_id: application_id,
        title: taskTitle,
        description: description || null,
        type: task_type,
        status: 'pending',
        due_at: due_at,
      })
      .select('id')
      .single()

    if (insertError || !newTask) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: insertError?.message || 'Failed to create task' 
        } as CreateTaskResponse),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Broadcast Realtime event
    await supabase.channel('tasks')
      .send({
        type: 'broadcast',
        event: 'task.created',
        payload: { 
          task_id: newTask.id, 
          application_id, 
          task_type,
          due_at 
        }
      })

    // Return success response
    return new Response(
      JSON.stringify({ 
        success: true, 
        task_id: newTask.id 
      } as CreateTaskResponse),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error instanceof Error ? error.message : 'Internal server error' 
      } as CreateTaskResponse),
      { 
        status: 400, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

