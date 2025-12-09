import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { Task } from '@/types'

/**
 * Hook to fetch tasks due today
 */
export function useTodayTasks() {
  return useQuery({
    queryKey: ['tasks', 'today'],
    queryFn: async (): Promise<Task[]> => {
      const today = new Date()
      const startOfDay = new Date(today.setHours(0, 0, 0, 0)).toISOString()
      const endOfDay = new Date(today.setHours(23, 59, 59, 999)).toISOString()

      const { data, error } = await supabase
        .from('tasks')
        .select('*')
        .gte('due_at', startOfDay)
        .lte('due_at', endOfDay)
        .order('due_at', { ascending: true })

      if (error) throw error
      return data || []
    },
  })
}

/**
 * Hook to mark a task as complete
 */
export function useMarkTaskComplete() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (taskId: string) => {
      const { data, error } = await supabase
        .from('tasks')
        .update({ 
          status: 'completed',
          completed_at: new Date().toISOString()
        })
        .eq('id', taskId)
        .select()
        .single()

      if (error) throw error
      return data
    },
    onSuccess: () => {
      // Invalidate and refetch tasks
      queryClient.invalidateQueries({ queryKey: ['tasks', 'today'] })
    },
  })
}

