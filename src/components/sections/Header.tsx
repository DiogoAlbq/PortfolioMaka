import React from 'react';
import { Menu, X, Sun, Moon, Globe } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { useScroll, useTransform } from 'motion/react';
import { Button } from '../ui/Button';
import { ThemeColors, Language, Currency } from '../../types';
import { createTheme } from '../../utils/theme.tsx';
import { MotionValue } from 'motion/react';

interface HeaderProps {
  language: Language;
  setLanguage: (lang: Language) => void;
  currency: Currency;
  setCurrency: (curr: Currency) => void;
  isDarkMode: boolean;
  setIsDarkMode: (dark: boolean) => void;
  theme: ThemeColors;
  scrollYProgress: MotionValue<number>;
  progressBarColor: MotionValue<string>;
  isMobileMenuOpen: boolean;
  setIsMobileMenuOpen: (open: boolean) => void;
  t: any;
}

export function Header({
  language,
  setLanguage,
  currency,
  setCurrency,
  isDarkMode,
  setIsDarkMode,
  theme,
  scrollYProgress,
  progressBarColor,
  isMobileMenuOpen,
  setIsMobileMenuOpen,
  t = {},
}: HeaderProps) {
  const handleLanguageChange = (lang: Language, curr: Currency) => {
    setLanguage(lang);
    setCurrency(curr);
    setIsMobileMenuOpen(false);
  };

  return (
    <>
      <div className="fixed top-0 left-0 right-0 h-1 z-[100] bg-transparent">
        <motion.div
          style={{
            height: '100%',
            width: '100%',
            background: progressBarColor,
            scaleX: scrollYProgress,
            transformOrigin: '0% 50%',
          }}
        />
      </div>

      <nav className={`fixed w-full top-0 z-50 border-b shadow-sm transition-colors duration-500 ${theme.navBg}`}>
        <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-center relative">
          <div className="hidden md:flex items-center gap-8 text-sm font-semibold transition-colors duration-500">
            <a href="#home" className={`transition-colors ${theme.navLink}`}>{t.nav.home}</a>
            <a href="#portfolio" className={`transition-colors ${theme.navLink}`}>{t.nav.portfolio}</a>
            <a href="#pricing" className={`transition-colors ${theme.navLink}`}>{t.nav.services}</a>
            <a href="#tos" className={`transition-colors ${theme.navLink}`}>{t.nav.terms}</a>

            <div className={`relative flex items-center p-1 rounded-full border-2 ml-4 ${isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-900/10 shadow-sm'
              }`}>
              <button
                onClick={() => handleLanguageChange('PT', 'BRL')}
                className={`relative px-4 py-1.5 text-xs font-bold rounded-full transition-colors duration-200 z-10 flex items-center gap-1.5 ${language === 'PT'
                  ? 'text-slate-950 font-black'
                  : isDarkMode ? 'text-slate-400 hover:text-slate-200' : 'text-slate-600 hover:text-slate-900'
                  }`}
              >
                {language === 'PT' && (
                  <motion.span
                    layoutId="activeLangDesktop"
                    className="absolute inset-0 bg-amber-400 rounded-full z-[-1] border-2 border-slate-900 shadow-sm"
                    transition={{ type: 'spring', stiffness: 400, damping: 25 }}
                  />
                )}
                <span>🇧🇷</span>
                <span>PT-BR</span>
              </button>
              <button
                onClick={() => handleLanguageChange('EN', 'USD')}
                className={`relative px-4 py-1.5 text-xs font-bold rounded-full transition-colors duration-200 z-10 flex items-center gap-1.5 ${language === 'EN'
                  ? 'text-slate-950 font-black'
                  : isDarkMode ? 'text-slate-400 hover:text-slate-200' : 'text-slate-600 hover:text-slate-900'
                  }`}
              >
                {language === 'EN' && (
                  <motion.span
                    layoutId="activeLangDesktop"
                    className="absolute inset-0 bg-amber-400 rounded-full z-[-1] border-2 border-slate-900 shadow-sm"
                    transition={{ type: 'spring', stiffness: 400, damping: 25 }}
                  />
                )}
                <span>🇺🇸</span>
                <span>EN</span>
              </button>
            </div>

            <Button
              variant="ghost"
              size="sm"
              onClick={() => setIsDarkMode(!isDarkMode)}
              aria-label={isDarkMode ? 'Ativar tema claro' : 'Ativar tema escuro'}
              className="ml-2"
            >
              {isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
            </Button>
          </div>

          <div className="md:hidden absolute right-6 flex items-center gap-2">
            <Button variant="ghost" size="sm" onClick={() => setIsDarkMode(!isDarkMode)} aria-label={isDarkMode ? 'Ativar tema claro' : 'Ativar tema escuro'}>
              {isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
            </Button>
            <Button variant="ghost" size="sm" onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)} aria-label={isMobileMenuOpen ? 'Fechar menu' : 'Abrir menu'}>
              {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </Button>
          </div>
        </div>

        <AnimatePresence>
          {isMobileMenuOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 50, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="md:hidden border-b border-white bg-white/90 backdrop-blur-xl overflow-hidden"
            >
              <div className={`flex flex-col px-6 py-4 gap-4 pb-8 font-semibold transition-colors duration-500 ${theme.mobileNavBg}`}>
                <a href="#home" onClick={() => setIsMobileMenuOpen(false)} className={`py-2 w-fit ${theme.navLink}`}>{t.nav.home}</a>
                <a href="#portfolio" onClick={() => setIsMobileMenuOpen(false)} className={`py-2 w-fit ${theme.navLink}`}>{t.nav.portfolio}</a>
                <a href="#pricing" onClick={() => setIsMobileMenuOpen(false)} className={`py-2 w-fit ${theme.navLink}`}>{t.nav.services}</a>
                <a href="#tos" onClick={() => setIsMobileMenuOpen(false)} className={`py-2 w-fit ${theme.navLink}`}>{t.nav.terms}</a>
                <div className="py-2 border-t border-slate-900/10 dark:border-white/10 mt-2">
                  <p className={`text-xs uppercase tracking-wider mb-2 opacity-60 ${isDarkMode ? 'text-slate-400' : 'text-slate-600'}`}>Idioma / Language</p>
                  <div className={`relative flex items-center p-1 rounded-full border-2 w-fit ${isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-900/10 shadow-sm'
                    }`}>
                    <button
                      onClick={() => handleLanguageChange('PT', 'BRL')}
                      className={`relative px-4 py-1.5 text-xs font-bold rounded-full transition-colors duration-200 z-10 flex items-center gap-1.5 ${language === 'PT'
                        ? 'text-slate-950 font-black'
                        : isDarkMode ? 'text-slate-400 hover:text-slate-200' : 'text-slate-600 hover:text-slate-900'
                        }`}
                    >
                      {language === 'PT' && (
                        <motion.span
                          layoutId="activeLangMobile"
                          className="absolute inset-0 bg-amber-400 rounded-full z-[-1] border-2 border-slate-900 shadow-sm"
                          transition={{ type: 'spring', stiffness: 400, damping: 25 }}
                        />
                      )}
                      <span>🇧🇷</span>
                      <span>PT-BR</span>
                    </button>
                    <button
                      onClick={() => handleLanguageChange('EN', 'USD')}
                      className={`relative px-4 py-1.5 text-xs font-bold rounded-full transition-colors duration-200 z-10 flex items-center gap-1.5 ${language === 'EN'
                        ? 'text-slate-950 font-black'
                        : isDarkMode ? 'text-slate-400 hover:text-slate-200' : 'text-slate-600 hover:text-slate-900'
                        }`}
                    >
                      {language === 'EN' && (
                        <motion.span
                          layoutId="activeLangMobile"
                          className="absolute inset-0 bg-amber-400 rounded-full z-[-1] border-2 border-slate-900 shadow-sm"
                          transition={{ type: 'spring', stiffness: 400, damping: 25 }}
                        />
                      )}
                      <span>🇺🇸</span>
                      <span>EN</span>
                    </button>
                  </div>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </nav>
    </>
  );
}