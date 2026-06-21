import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { XCircle, CheckCircle2 } from 'lucide-react';

interface ToastProps {
  message: string;
  type?: 'success' | 'error' | 'info' | 'warning';
  onClose: () => void;
  duration?: number;
}

export function Toast({ message, type = 'success', onClose, duration = 4000 }: ToastProps) {
  const icons = {
    success: <CheckCircle2 className="w-6 h-6 text-emerald-600" />,
    error: <svg className="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" strokeWidth="2"/><line x1="15" y1="9" x2="9" y2="15" strokeWidth="2" strokeLinecap="round"/><line x1="9" y1="9" x2="15" y2="15" strokeWidth="2" strokeLinecap="round"/></svg>,
    info: <svg className="w-6 h-6 text-sky-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" strokeWidth="2"/><line x1="12" y1="16" x2="12" y2="12" strokeWidth="2" strokeLinecap="round"/><line x1="12" y1="8" x2="12.01" y2="8" strokeWidth="2" strokeLinecap="round"/></svg>,
    warning: <svg className="w-6 h-6 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" strokeWidth="2"/><line x1="12" y1="9" x2="12" y2="13" strokeWidth="2" strokeLinecap="round"/><line x1="12" y1="17" x2="12.01" y2="17" strokeWidth="2" strokeLinecap="round"/></svg>,
  };

  const backgrounds = {
    success: 'bg-emerald-50 border-emerald-200 dark:bg-emerald-950/30 dark:border-emerald-900',
    error: 'bg-red-50 border-red-200 dark:bg-red-950/30 dark:border-red-900',
    info: 'bg-sky-50 border-sky-200 dark:bg-sky-950/30 dark:border-sky-900',
    warning: 'bg-amber-50 border-amber-200 dark:bg-amber-950/30 dark:border-amber-900',
  };

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0, y: 50, scale: 0.9 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        exit={{ opacity: 0, y: 50, scale: 0.9 }}
        className={`fixed bottom-6 right-6 z-[200] max-w-sm w-full p-4 rounded-xl border-2 shadow-[8px_8px_0px_#1e293b] dark:shadow-[8px_8px_0px_#020617] flex items-start gap-4 ${backgrounds[type]}`}
      >
        <div className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0">
          {icons[type]}
        </div>
        <div className="flex-1 pt-1">
          <p className="font-bold text-sm text-slate-800 dark:text-slate-200 whitespace-pre-line">{message}</p>
        </div>
        <button
          onClick={onClose}
          className="text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-slate-300"
        >
          <XCircle className="w-5 h-5" />
        </button>
      </motion.div>
    </AnimatePresence>
  );
}

interface ToastContainerProps {
  toasts: Array<{ id: string; message: string; type?: 'success' | 'error' | 'info' | 'warning' }>;
  onClose: (id: string) => void;
}

export function ToastContainer({ toasts, onClose }: ToastContainerProps) {
  return (
    <AnimatePresence>
      {toasts.map((toast) => (
        <motion.div
          key={toast.id}
          initial={{ opacity: 0, y: 50, scale: 0.9 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 50, scale: 0.9 }}
          className={`fixed bottom-6 right-6 z-[200] max-w-sm w-full p-4 rounded-xl border-2 shadow-[8px_8px_0px_#1e293b] dark:shadow-[8px_8px_0px_#020617] flex items-start gap-4 ${
            toast.type === 'success'
              ? 'bg-emerald-50 border-emerald-200 dark:bg-emerald-950/30 dark:border-emerald-900'
              : toast.type === 'error'
              ? 'bg-red-50 border-red-200 dark:bg-red-950/30 dark:border-red-900'
              : toast.type === 'info'
              ? 'bg-sky-50 border-sky-200 dark:bg-sky-950/30 dark:border-sky-900'
              : 'bg-amber-50 border-amber-200 dark:bg-amber-950/30 dark:border-amber-900'
          }`}
        >
          <div className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0">
            {toast.type === 'success' && <CheckCircle2 className="w-6 h-6 text-emerald-600" />}
            {toast.type === 'error' && (
              <svg className="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" strokeWidth="2" />
                <line x1="15" y1="9" x2="9" y2="15" strokeWidth="2" strokeLinecap="round" />
                <line x1="9" y1="9" x2="15" y2="15" strokeWidth="2" strokeLinecap="round" />
              </svg>
            )}
            {toast.type === 'info' && (
              <svg className="w-6 h-6 text-sky-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" strokeWidth="2" />
                <line x1="12" y1="16" x2="12" y2="12" strokeWidth="2" strokeLinecap="round" />
                <line x1="12" y1="8" x2="12.01" y2="8" strokeWidth="2" strokeLinecap="round" />
              </svg>
            )}
            {toast.type === 'warning' && (
              <svg className="w-6 h-6 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" strokeWidth="2" />
                <line x1="12" y1="9" x2="12" y2="13" strokeWidth="2" strokeLinecap="round" />
                <line x1="12" y1="17" x2="12.01" y2="17" strokeWidth="2" strokeLinecap="round" />
              </svg>
            )}
          </div>
          <div className="flex-1 pt-1">
            <p className="font-bold text-sm text-slate-800 dark:text-slate-200 whitespace-pre-line">{toast.message}</p>
          </div>
          <button
            onClick={() => onClose(toast.id)}
            className="text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-slate-300"
          >
            <XCircle className="w-5 h-5" />
          </button>
        </motion.div>
      ))}
    </AnimatePresence>
  );
}