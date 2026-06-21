import React, { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence, useScroll, useTransform } from 'motion/react';
import {
  Palette,
  Sparkles,
  Instagram,
  MessageSquare,
  FileText,
  CheckCircle2,
  XCircle
} from 'lucide-react';

import {
  exchangeRate,
  t,
  artItems,
  videoItems,
  nsfwItems,
  heroBgImages,
  PortfolioItem
} from './data';
import { useLocalStorage } from './hooks/useLocalStorage';
import { createTheme, formatPrice } from './utils/theme.tsx';

const checkDarkMode = (): boolean => {
  if (typeof window === 'undefined') return false;
  const saved = localStorage.getItem('maka_darkMode');
  if (saved !== null) return saved === 'true';
  return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
};
import { Header } from './components/sections/Header';
import { Hero } from './components/sections/Hero';
import { Portfolio } from './components/sections/Portfolio';
import { Pricing } from './components/sections/Pricing';
import { TOS } from './components/sections/TOS';
import { Footer } from './components/sections/Footer';
import { NSFWModal } from './components/sections/NSFWModal';
import { ThemeColors, Language, Currency, PortfolioTab, PricingTab, Plan } from './types';

export default function App() {
  const [activeTab, setActiveTab] = useState<PricingTab>('digital');
  const [activePortfolioTab, setActivePortfolioTab] = useState<PortfolioTab>('all');
  
  const [currency, setCurrency] = useLocalStorage<Currency>('maka_currency', 'BRL');
  const [language, setLanguage] = useLocalStorage<Language>('maka_language', 'PT');
  const [isDarkMode, setIsDarkMode] = useLocalStorage<boolean>('maka_darkMode', checkDarkMode());
  
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [heroBgIndex, setHeroBgIndex] = useState(0);
  const [nsfwDialogOpen, setNsfwDialogOpen] = useState(false);
  const [nsfwTargetUrl, setNsfwTargetUrl] = useState('');
  const [showNsfwPortfolio, setShowNsfwPortfolio] = useState(false);
  const [selectedAddons, setSelectedAddons] = useState<Record<string, string[]>>({});

  const { scrollYProgress } = useScroll();
  const progressBarColor = useTransform(
    scrollYProgress,
    [0, 0.5, 1],
    ["#f59e0b", "#f97316", "#ef4444"]
  );

  const theme = createTheme(isDarkMode, progressBarColor);
  const tLang = t[language];

  useEffect(() => {
    const root = document.documentElement;
    if (isDarkMode) {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
  }, [isDarkMode]);

  useEffect(() => {
    const timer = setInterval(() => {
      setHeroBgIndex((prev) => (prev + 1) % heroBgImages.length);
    }, 5000);
    return () => clearInterval(timer);
  }, []);

  const handleNsfwClick = useCallback((e: React.MouseEvent<HTMLAnchorElement>, url: string) => {
    e.preventDefault();
    setNsfwTargetUrl(url);
    setNsfwDialogOpen(true);
  }, []);

  const handlePortfolioTabClick = useCallback((tabId: string) => {
    if (tabId === 'nsfw' && !showNsfwPortfolio) {
      setNsfwTargetUrl('tab');
      setNsfwDialogOpen(true);
    } else {
      setActivePortfolioTab(tabId as PortfolioTab);
    }
  }, [showNsfwPortfolio]);

  const confirmNsfw = useCallback(() => {
    setNsfwDialogOpen(false);
    if (nsfwTargetUrl === 'tab') {
      setShowNsfwPortfolio(true);
      setActivePortfolioTab('nsfw');
    } else if (nsfwTargetUrl) {
      window.open(nsfwTargetUrl, '_blank', 'noopener,noreferrer');
    }
    setNsfwTargetUrl('');
  }, [nsfwTargetUrl]);

  const portfolioItems = React.useMemo(() => {
    if (activePortfolioTab === 'all') {
      return [...artItems, ...videoItems];
    }
    if (activePortfolioTab === 'video') return videoItems;
    if (activePortfolioTab === 'nsfw') return nsfwItems;
    return artItems;
  }, [activePortfolioTab]);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className={`min-h-screen font-sans relative transition-colors duration-500 ${theme.bg}`}
    >
      <Header
        language={language}
        setLanguage={setLanguage}
        currency={currency}
        setCurrency={setCurrency}
        isDarkMode={isDarkMode}
        setIsDarkMode={setIsDarkMode}
        theme={theme}
        scrollYProgress={scrollYProgress}
        progressBarColor={progressBarColor}
        isMobileMenuOpen={isMobileMenuOpen}
        setIsMobileMenuOpen={setIsMobileMenuOpen}
        t={tLang}
      />

      <main className="relative z-10 w-full h-full">
        <Hero
          theme={theme}
          t={tLang}
          heroBgImages={heroBgImages}
          heroBgIndex={heroBgIndex}
          isDarkMode={isDarkMode}
        />

        <Portfolio
          theme={theme}
          t={tLang}
          activeTab={activePortfolioTab}
          setActiveTab={setActivePortfolioTab}
          portfolioItems={portfolioItems}
          showNsfwPortfolio={showNsfwPortfolio}
          setShowNsfwPortfolio={setShowNsfwPortfolio}
          nsfwTargetUrl={nsfwTargetUrl}
          setNsfwTargetUrl={setNsfwTargetUrl}
          nsfwDialogOpen={nsfwDialogOpen}
          setNsfwDialogOpen={setNsfwDialogOpen}
        />

        <Pricing
          theme={theme}
          t={tLang}
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          pricingPlans={tLang.pricingPlans}
          currency={currency}
          selectedAddons={selectedAddons}
          setSelectedAddons={setSelectedAddons}
          isDarkMode={isDarkMode}
        />

        <TOS theme={theme} t={tLang} />

        <Footer
          theme={theme}
          t={tLang}
          isDarkMode={isDarkMode}
          handleNsfwClick={handleNsfwClick}
        />
      </main>

      <NSFWModal
        isOpen={nsfwDialogOpen}
        onClose={() => setNsfwDialogOpen(false)}
        onConfirm={confirmNsfw}
        t={tLang}
        theme={theme}
        isDarkMode={isDarkMode}
      />
    </motion.div>
  );
}// force rebuild
