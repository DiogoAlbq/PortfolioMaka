import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ThemeColors } from '../../types';

interface NSFWModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  t: any;
  theme: ThemeColors;
  isDarkMode: boolean;
}

export function NSFWModal({ isOpen, onClose, onConfirm, t, theme, isDarkMode }: NSFWModalProps) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[110] flex items-center justify-center px-4 backdrop-blur-md bg-slate-950/40"
        >
          <motion.div
            initial={{ scale: 0.95, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            exit={{ scale: 0.95, opacity: 0, y: -20 }}
            className={`max-w-md w-full p-8 rounded-3xl border-2 shadow-2xl ${isDarkMode ? 'bg-slate-900 border-red-900 text-slate-200' : 'bg-white border-red-200 text-slate-800'}`}
          >
            <div className="mx-auto w-16 h-16 rounded-full bg-red-100 dark:bg-red-900/30 flex items-center justify-center mb-6">
              <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-red-600 dark:text-red-400">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                <line x1="12" y1="9" x2="12" y2="13"/>
                <line x1="12" y1="17" x2="12.01" y2="17"/>
              </svg>
            </div>
            <h3 className="text-2xl font-bold text-center mb-4">{t.nsfwModal.title}</h3>
            <p className="text-center font-medium mb-8 opacity-80">
              {t.nsfwModal.message}
            </p>

            <div className="flex flex-col gap-3">
              <button
                onClick={onConfirm}
                className="w-full py-4 rounded-xl font-bold text-white bg-red-600 hover:bg-red-700 transition-colors"
              >
                {t.nsfwModal.confirm}
              </button>
              <button
                onClick={onClose}
                className={`w-full py-4 rounded-xl font-bold border-2 transition-colors ${isDarkMode ? 'border-slate-700 hover:bg-slate-800' : 'border-slate-200 hover:bg-slate-50'}`}
              >
                {t.nsfwModal.cancel}
              </button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}