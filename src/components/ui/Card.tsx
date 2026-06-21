import React, { forwardRef, HTMLAttributes } from 'react';
import { motion } from 'motion/react';

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'pricing' | 'portfolio' | 'tos';
  hover?: boolean;
  rotate?: number;
  popular?: boolean;
}

export const Card = forwardRef<HTMLDivElement, CardProps>(
  (
    {
      children,
      variant = 'default',
      hover = true,
      rotate = 0,
      popular = false,
      className = '',
      style,
      ...props
    },
    ref
  ) => {
    const variants = {
      default: 'bg-white border-white hover:shadow-xl dark:bg-slate-900 dark:border-slate-800',
      pricing: 'bg-[#fffcf0] border-slate-900 shadow-[8px_8px_0px_#1e293b] dark:bg-slate-900 dark:border-slate-700 dark:shadow-[8px_8px_0px_#020617]',
      portfolio: 'bg-gradient-to-br border-2 shadow-sm',
      tos: 'border-4 shadow-[8px_8px_0px_#1e293b] dark:shadow-[8px_8px_0px_#020617]',
    };

    const hoverStyles = hover
      ? 'hover:-translate-y-2 transition-all duration-500 hover:shadow-[12px_12px_0px_#1e293b] dark:hover:shadow-[12px_12px_0px_#020617]'
      : '';

    const popularStyles = popular
      ? 'z-10 scale-105'
      : '';

    const rotateStyle = rotate !== 0 ? `rotate-${rotate > 0 ? '' : '-'}${Math.abs(rotate)}` : '';

    return (
      <motion.div
        ref={ref}
        className={`${variants[variant]} ${hoverStyles} ${popularStyles} ${rotateStyle} ${className}`}
        style={{ ...style, transformOrigin: 'center' }}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -20 }}
        transition={{ duration: 0.3 }}
        {...props}
      >
        {children}
      </motion.div>
    );
  }
);

Card.displayName = 'Card';

export const StickyTape = ({ rotation = -6 }: { rotation?: number }) => (
  <div className="absolute -top-5 left-1/2 -translate-x-1/2 z-20" style={{ transform: `rotate(${rotation}deg)` }}>
    <svg width="120" height="40" viewBox="0 0 120 40" fill="none" className="drop-shadow-[2px_3px_0px_rgba(15,23,42,1)]" xmlns="http://www.w3.org/2000/svg">
      <path d="M 10 4 L 110 4 L 117 9 L 109 15 L 119 22 L 111 28 L 116 36 L 6 36 L 2 28 L 10 21 L 1 13 L 8 7 Z" fill="#fef08a" stroke="#0f172a" strokeWidth="3" strokeLinejoin="round" />
    </svg>
  </div>
);

export const PopularBadge = ({ children }: { children: React.ReactNode }) => (
  <div className="absolute -top-4 -right-4 bg-red-500 border-4 text-white text-xs font-black px-4 py-2 uppercase tracking-wider rotate-[15deg] z-30 shadow-[4px_4px_0px_#1e293b] dark:border-slate-800 dark:shadow-[4px_4px_0px_#020617]">
    {children}
  </div>
);