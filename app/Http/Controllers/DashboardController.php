<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;
use Inertia\Inertia;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Estadísticas generales
        $tasks = [
            'total' => $user->tasks()->count(),
            'pending' => $user->tasks()->where('status', 'pendiente')->count(),
            'in_progress' => $user->tasks()->where('status', 'en_proceso')->count(),
            'completed' => $user->tasks()->where('status', 'terminado')->count(),
            'overdue' => $user->tasks()
                ->where('status', '!=', 'terminado')
                ->where('due_date', '<', now())
                ->count(),
            'today' => $user->tasks()
                ->where('status', '!=', 'terminado')
                ->whereDate('due_date', now())
                ->count(),
        ];

        // Tareas recientes (últimas 5)
        $recentTasks = $user->tasks()
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get(['id', 'title', 'status', 'due_date']);

        return Inertia::render('Dashboard', [
            'tasks' => $tasks,
            'recentTasks' => $recentTasks,
        ]);
    }
}