import React from 'react';
import { ThemeColors } from '../types';
import { MotionValue } from 'motion/react';

export function createTheme(isDarkMode: boolean, progressBarColor: MotionValue<string>): ThemeColors {
  return {
    bg: isDarkMode
      ? 'bg-slate-950 text-slate-400 selection:bg-amber-500/30 selection:text-amber-200'
      : 'bg-slate-50 text-slate-600 selection:bg-amber-200 selection:text-amber-900',
    navBg: isDarkMode
      ? 'bg-slate-950/80 border-slate-900 backdrop-blur-xl'
      : 'bg-white/70 border-white backdrop-blur-xl',
    mobileNavBg: isDarkMode
      ? 'bg-slate-900/95 border-slate-800 text-slate-300'
      : 'bg-white/90 border-white text-slate-600',
    navLink: isDarkMode
      ? 'text-slate-300 hover:text-amber-400 transition-colors'
      : 'text-slate-600 hover:text-amber-600 transition-colors',
    socialBtn: isDarkMode
      ? 'border-slate-800 text-slate-400 bg-slate-900/50 hover:text-amber-400 hover:border-amber-500/50'
      : 'border-slate-300 text-slate-600 hover:text-amber-600 hover:border-amber-400 bg-white/50',
    secondaryBtn: isDarkMode
      ? 'bg-slate-900 hover:bg-slate-800 border-slate-700 text-slate-300'
      : 'bg-white hover:bg-slate-50 border-slate-200 text-slate-700',
    sectionBg: isDarkMode
      ? 'bg-slate-900/40 border-slate-900 min-h-[500px]'
      : 'bg-white/40 border-white min-h-[500px]',
    tabWrapper: isDarkMode
      ? 'bg-slate-900/80 border-slate-800'
      : 'bg-white/60 border-white/50',
    tabDefault: isDarkMode
      ? 'text-slate-400 hover:text-amber-400 hover:bg-slate-800'
      : 'text-slate-600 hover:text-amber-600 hover:bg-white/80',
    card: isDarkMode
      ? 'bg-slate-900 border-slate-800 hover:border-slate-700 shadow-sm'
      : 'bg-white border-white hover:shadow-xl',
    pricingCard: isDarkMode
      ? 'bg-slate-900 border-slate-700 shadow-[8px_8px_0px_#020617] hover:shadow-[12px_12px_0px_#020617]'
      : 'bg-[#fffcf0] border-slate-900 shadow-[8px_8px_0px_#1e293b] hover:shadow-[12px_12px_0px_#1e293b]',
    tapeFill: '#fef08a',
    pricingSelectBase: isDarkMode
      ? 'bg-slate-800 text-slate-300 border-slate-700 shadow-[4px_4px_0px_#020617] hover:shadow-[6px_6px_0px_#020617] active:shadow-[0px_0px_0px_#020617]'
      : 'bg-white text-slate-900 border-slate-900 shadow-[4px_4px_0px_#1e293b] hover:shadow-[6px_6px_0px_#1e293b] active:shadow-[0px_0px_0px_#1e293b]',
    pricingSelectPopular: isDarkMode
      ? 'bg-amber-500 text-slate-950 border-slate-700 shadow-[4px_4px_0px_#020617] hover:shadow-[6px_6px_0px_#020617] active:shadow-[0px_0px_0px_#020617]'
      : 'bg-amber-400 text-slate-900 border-slate-900 shadow-[4px_4px_0px_#1e293b] hover:shadow-[6px_6px_0px_#1e293b] active:shadow-[0px_0px_0px_#1e293b]',
    addonLabel: isDarkMode ? 'text-slate-300' : 'text-slate-800',
    addonPrice: isDarkMode
      ? 'bg-slate-800 border-slate-700 text-slate-200 shadow-[2px_2px_0px_#020617]'
      : 'bg-amber-200 border-slate-900 text-slate-900 shadow-[2px_2px_0px_#1e293b]',
    heading: isDarkMode ? 'text-slate-100' : 'text-slate-900',
    subheading: isDarkMode ? 'text-slate-400' : 'text-slate-600',
    heroBadge: isDarkMode
      ? 'border-slate-800 bg-slate-900/80 text-slate-300'
      : 'border-white bg-white/60 text-slate-700',
    overlayEnd: isDarkMode
      ? 'from-slate-950 via-slate-950/60'
      : 'from-slate-50 via-slate-50/45',
    overlaySide: isDarkMode
      ? 'from-slate-950/60 to-slate-950/60'
      : 'from-slate-50/20 to-slate-50/20',
    tosBoxGood: isDarkMode
      ? 'bg-slate-900 border-slate-700 border-4 shadow-[8px_8px_0px_#020617] hover:shadow-[12px_12px_0px_#020617]'
      : 'bg-[#f0fdf4] border-slate-900 border-4 shadow-[8px_8px_0px_#1e293b] hover:shadow-[12px_12px_0px_#1e293b]',
    tosBoxBad: isDarkMode
      ? 'bg-slate-900 border-slate-700 border-4 shadow-[8px_8px_0px_#020617] hover:shadow-[12px_12px_0px_#020617]'
      : 'bg-[#fff5f5] border-slate-900 border-4 shadow-[8px_8px_0px_#1e293b] hover:shadow-[12px_12px_0px_#1e293b]',
    tosBoxInfo: isDarkMode
      ? 'bg-slate-900 border-slate-700 border-4 shadow-[8px_8px_0px_#020617] hover:shadow-[12px_12px_0px_#020617]'
      : 'bg-[#f8fafc] border-slate-900 border-4 shadow-[8px_8px_0px_#1e293b] hover:shadow-[12px_12px_0px_#1e293b]',
    tosTitleGood: isDarkMode
      ? 'bg-emerald-950/50 text-emerald-400 border-2 border-emerald-500/30'
      : 'bg-emerald-100 text-emerald-800 border-2 border-slate-900 shadow-[2px_2px_0px_#1e293b]',
    tosTitleBad: isDarkMode
      ? 'bg-red-950/50 text-red-400 border-2 border-red-500/30'
      : 'bg-red-100 text-red-800 border-2 border-slate-900 shadow-[2px_2px_0px_#1e293b]',
    tosTitleInfo: isDarkMode
      ? 'bg-sky-950/50 text-sky-400 border-2 border-sky-500/30'
      : 'bg-sky-100 text-sky-800 border-2 border-slate-900 shadow-[2px_2px_0px_#1e293b]',
    footerIcon: isDarkMode
      ? 'border-slate-800 bg-slate-900 text-slate-400 hover:text-amber-500 hover:border-amber-500'
      : 'border-slate-300 bg-transparent text-slate-600 hover:text-amber-600 hover:border-amber-400',
  };
}

export function formatPrice(
  value: number,
  currency: 'BRL' | 'USD',
  isAddon = false
): string {
  if (isNaN(value)) return '';

  if (currency === 'BRL') {
    return (isAddon ? '+' : '') + `R$${value.toFixed(0)}`;
  }
  return (isAddon ? '+' : '') + `$${value.toFixed(0)}`;
}

export function getGradientForType(type: 'image' | 'video', category: 'art' | 'video' | 'nsfw'): string {
  const gradients = {
    art: {
      image: 'from-amber-200 to-yellow-200',
      video: 'from-orange-200 to-yellow-200',
    },
    video: {
      image: 'from-orange-200 to-yellow-200',
      video: 'from-red-200 to-orange-200',
    },
    nsfw: {
      image: 'from-red-200 to-rose-200',
      video: 'from-rose-200 to-pink-200',
    },
  };
  return gradients[category][type];
}

export function getIconColorForCategory(category: 'art' | 'video' | 'nsfw'): string {
  const colors = {
    art: 'text-amber-600',
    video: 'text-orange-600',
    nsfw: 'text-red-600',
  };
  return colors[category];
}

export function getIconForType(type: 'image' | 'video'): React.ReactElement {
  if (type === 'video') {
    return (
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-10 h-10">
        <polygon points="23 7 16 12 23 17 23 7" />
        <rect x="1" y="5" width="15" height="14" rx="2" ry="2" />
      </svg>
    );
  }
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-10 h-10">
      <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
      <circle cx="8.5" cy="8.5" r="1.5" />
      <polyline points="21 15 16 10 5 21" />
    </svg>
  );
}