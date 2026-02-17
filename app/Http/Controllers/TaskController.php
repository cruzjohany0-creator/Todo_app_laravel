<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;
use Inertia\Inertia;

class TaskController extends Controller
{
    /**
     * Mostrar lista de tareas
     */
    public function index(Request $request)
    {
        $status = $request->get('status');

        $query = $request->user()->tasks();

        if ($status) {
            $query->where('status', $status);
        }

        $tasks = $query->orderBy('due_date', 'asc')->get();

        return Inertia::render('Tasks/Index', [
            'tasks' => $tasks,
            'currentStatus' => $status,
        ]);
    }

    /**
     * Crear nueva tarea
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:5000',
            'due_date' => 'required|date',
            'status' => 'required|in:pendiente,en_proceso,terminado',
        ], [
            'title.required' => 'El título es obligatorio',
            'title.max' => 'El título no puede tener más de 255 caracteres',
            'description.max' => 'La descripción no puede tener más de 5000 caracteres',
            'due_date.required' => 'La fecha de vencimiento es obligatoria',
            'due_date.date' => 'La fecha de vencimiento debe ser una fecha válida',
            'status.required' => 'El estado es obligatorio',
            'status.in' => 'El estado debe ser: pendiente, en proceso o terminado',
        ]);

        $task = $request->user()->tasks()->create($validated);

        return back()->with('success', 'Tarea creada exitosamente');
    }

    /**
     * Actualizar tarea existente
     */
    public function update(Request $request, Task $task)
    {
        // Verificar autorización
        if ($task->user_id !== $request->user()->id) {
            abort(403, 'No tienes permiso para actualizar esta tarea');
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:5000',
            'due_date' => 'required|date',
            'status' => 'required|in:pendiente,en_proceso,terminado',
        ], [
            'title.required' => 'El título es obligatorio',
            'title.max' => 'El título no puede tener más de 255 caracteres',
            'description.max' => 'La descripción no puede tener más de 5000 caracteres',
            'due_date.required' => 'La fecha de vencimiento es obligatoria',
            'due_date.date' => 'La fecha de vencimiento debe ser una fecha válida',
            'status.required' => 'El estado es obligatorio',
            'status.in' => 'El estado debe ser: pendiente, en proceso o terminado',
        ]);

        $task->update($validated);

        return back()->with('success', 'Tarea actualizada exitosamente');
    }

    /**
     * Eliminar tarea
     */
    public function destroy(Request $request, Task $task)
    {
        // Verificar autorización
        if ($task->user_id !== $request->user()->id) {
            abort(403, 'No tienes permiso para eliminar esta tarea');
        }

        $task->delete();

        return back()->with('success', 'Tarea eliminada exitosamente');
    }

    /**
     * Actualizar solo el estado de una tarea
     */
    public function updateStatus(Request $request, Task $task)
    {
        // Verificar autorización
        if ($task->user_id !== $request->user()->id) {
            abort(403, 'No tienes permiso para actualizar esta tarea');
        }

        $validated = $request->validate([
            'status' => 'required|in:pendiente,en_proceso,terminado',
        ], [
            'status.required' => 'El estado es obligatorio',
            'status.in' => 'El estado debe ser: pendiente, en proceso o terminado',
        ]);

        $task->update($validated);

        return back()->with('success', 'Estado actualizado exitosamente');
    }
}