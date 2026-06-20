import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence, useScroll, useTransform } from 'motion/react';
import { 
  Palette, 
  Video, 
  CheckCircle2,
  XCircle,
  Instagram,
  Twitter,
  Youtube,
  Menu,
  X,
  Mail,
  Gamepad2,
  Sparkles,
  MessageSquare,
  Twitch,
  Sun,
  Moon,
  Info,
  FileText
} from 'lucide-react';

import { 
  exchangeRate, 
  t, 
  artItems, 
  videoItems, 
  nsfwItems, 
  heroBgImages 
} from './data';

interface PlanAddon {
  name: string;
  price: string;
}

interface Plan {
  title: string;
  price: string;
  desc?: string;
  popular?: boolean;
  addons: PlanAddon[];
}

export default function App() {
  const [activeTab, setActiveTab] = useState<'digital' | 'special'>('digital');
  const [activePortfolioTab, setActivePortfolioTab] = useState<'all' | 'video' | 'nsfw'>('all');
  const [currency, setCurrency] = useState<'BRL' | 'USD'>('BRL');
  const [language, setLanguage] = useState<'PT' | 'EN'>('PT');
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [heroBgIndex, setHeroBgIndex] = useState(0);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [nsfwDialogOpen, setNsfwDialogOpen] = useState(false);
  const [nsfwTargetUrl, setNsfwTargetUrl] = useState('');
  const [showNsfwPortfolio, setShowNsfwPortfolio] = useState(false);
  const [selectedAddons, setSelectedAddons] = useState<Record<string, string[]>>({});

  const toggleAddon = (planKey: string, addonName: string) => {
    setSelectedAddons(prev => {
      const current = prev[planKey] || [];
      const updated = current.includes(addonName)
        ? current.filter(name => name !== addonName)
        : [...current, addonName];
      return { ...prev, [planKey]: updated };
    });
  };

  const calculatePlanTotal = (plan: Plan, planKey: string) => {
    const basePrice = parseFloat(plan.price.replace(/[^0-9.]/g, '')) || 0;
    const selected = selectedAddons[planKey] || [];
    
    const addonsTotal = selected.reduce((sum, addonName) => {
      const addon = plan.addons.find((a) => a.name === addonName);
      if (addon) {
        const addonPrice = parseFloat(addon.price.replace(/[^0-9.]/g, '')) || 0;
        return sum + addonPrice;
      }
      return sum;
    }, 0);

    return basePrice + addonsTotal;
  };

  const [toastMessage, setToastMessage] = useState('');
  const [showToast, setShowToast] = useState(false);

  const handleSelectPlan = async (plan: Plan, planKey: string, totalPrice: number) => {
    const selected = selectedAddons[planKey] || [];
    const tToast = t[language].toast;

    const details = [
      tToast.greeting,
      `${tToast.plan}: ${plan.title}`,
      `${tToast.basePrice}: ${formatPrice(plan.price)} ${currency}`,
      selected.length > 0 ? `${tToast.addons}: ${selected.join(', ')}` : null,
      `${tToast.total}: ${formatPrice(totalPrice.toString())} ${currency}`
    ].filter(Boolean).join('\n');

    try {
      await navigator.clipboard.writeText(details);
      setToastMessage(tToast.success);
      setShowToast(true);
      setTimeout(() => setShowToast(false), 3000);
    } catch (err) {
      console.error('Failed to copy text: ', err);
    }
  };

  const { scrollYProgress } = useScroll();
  const progressBarColor = useTransform(
    scrollYProgress,
    [0, 0.5, 1],
    ["#f59e0b", "#f97316", "#ef4444"]
  );

  const theme = {
    bg: isDarkMode ? 'bg-slate-950 text-slate-400 selection:bg-amber-500/30 selection:text-amber-200' : 'bg-slate-50 text-slate-600 selection:bg-amber-200 selection:text-amber-900',
    navBg: isDarkMode ? 'bg-slate-950/80 border-slate-900' : 'bg-white/70 border-white',
    mobileNavBg: isDarkMode ? 'bg-slate-900/95 border-slate-800 text-slate-300' : 'bg-white/90 border-white text-slate-600',
    navLink: isDarkMode ? 'text-slate-300 hover:text-amber-400' : 'text-slate-600 hover:text-amber-600',
    socialBtn: isDarkMode ? 'border-slate-800 text-slate-400 bg-slate-900/50 hover:text-amber-400 hover:border-amber-500/50' : 'border-slate-300 text-slate-600 hover:text-amber-600 hover:border-amber-400 bg-white/50',
    secondaryBtn: isDarkMode ? 'bg-slate-900 hover:bg-slate-800 border-slate-700 text-slate-300' : 'bg-white hover:bg-slate-50 border-slate-200 text-slate-700',
    sectionBg: isDarkMode ? 'bg-slate-900/40 border-slate-900 min-h-[500px]' : 'bg-white/40 border-white min-h-[500px]',
    tabWrapper: isDarkMode ? 'bg-slate-900/80 border-slate-800' : 'bg-white/60 border-white/50',
    tabDefault: isDarkMode ? 'text-slate-400 hover:text-amber-400 hover:bg-slate-800' : 'text-slate-600 hover:text-amber-600 hover:bg-white/80',
    card: isDarkMode ? 'bg-slate-900 border-slate-800 hover:border-slate-700 shadow-sm' : 'bg-white border-white hover:shadow-xl',
    pricingCard: isDarkMode ? 'bg-slate-900 border-slate-700 shadow-[8px_8px_0px_#020617] hover:shadow-[12px_12px_0px_#020617]' : 'bg-[#fffcf0] border-slate-900 shadow-[8px_8px_0px_#1e293b] hover:shadow-[12px_12px_0px_#1e293b]',
    tapeFill: '#fef08a',
    pricingSelectBase: isDarkMode ? 'bg-slate-800 text-slate-300 border-slate-700 shadow-[4px_4px_0px_#020617] hover:shadow-[6px_6px_0px_#020617] active:shadow-[0px_0px_0px_#020617]' : 'bg-white text-slate-900 border-slate-900 shadow-[4px_4px_0px_#1e293b] hover:shadow-[6px_6px_0px_#1e293b] active:shadow-[0px_0px_0px_#1e293b]',
    pricingSelectPopular: isDarkMode ? 'bg-amber-500 text-slate-950 border-slate-700 shadow-[4px_4px_0px_#020617] hover:shadow-[6px_6px_0px_#020617] active:shadow-[0px_0px_0px_#020617]' : 'bg-amber-400 text-slate-900 border-slate-900 shadow-[4px_4px_0px_#1e293b] hover:shadow-[6px_6px_0px_#1e293b] active:shadow-[0px_0px_0px_#1e293b]',
    addonLabel: isDarkMode ? 'text-slate-300' : 'text-slate-800',
    addonPrice: isDarkMode ? 'bg-slate-800 border-slate-700 text-slate-200 shadow-[2px_2px_0px_#020617]' : 'bg-amber-200 border-slate-900 text-slate-900 shadow-[2px_2px_0px_#1e293b]',
    heading: isDarkMode ? 'text-slate-100' : 'text-slate-900',
    subheading: isDarkMode ? 'text-slate-400' : 'text-slate-600',
    heroBadge: isDarkMode ? 'border-slate-800 bg-slate-900/80 text-slate-300' : 'border-white bg-white/60 text-slate-700',
    overlayEnd: isDarkMode ? 'from-slate-950 via-slate-950/60' : 'from-slate-50 via-slate-50/45',
    overlaySide: isDarkMode ? 'from-slate-950/60 to-slate-950/60' : 'from-slate-50/20 to-slate-50/20',
    tosBoxGood: isDarkMode ? 'bg-slate-900 border-slate-700 border-4 shadow-[8px_8px_0px_#020617] hover:shadow-[12px_12px_0px_#020617]' : 'bg-[#f0fdf4] border-slate-900 border-4 shadow-[8px_8px_0px_#1e293b] hover:shadow-[12px_12px_0px_#1e293b]',
    tosBoxBad: isDarkMode ? 'bg-slate-900 border-slate-700 border-4 shadow-[8px_8px_0px_#020617] hover:shadow-[12px_12px_0px_#020617]' : 'bg-[#fff5f5] border-slate-900 border-4 shadow-[8px_8px_0px_#1e293b] hover:shadow-[12px_12px_0px_#1e293b]',
    tosBoxInfo: isDarkMode ? 'bg-slate-900 border-slate-700 border-4 shadow-[8px_8px_0px_#020617] hover:shadow-[12px_12px_0px_#020617]' : 'bg-[#f8fafc] border-slate-900 border-4 shadow-[8px_8px_0px_#1e293b] hover:shadow-[12px_12px_0px_#1e293b]',
    tosTitleGood: isDarkMode ? 'bg-emerald-950/50 text-emerald-400 border-2 border-emerald-500/30' : 'bg-emerald-100 text-emerald-800 border-2 border-slate-900 shadow-[2px_2px_0px_#1e293b]',
    tosTitleBad: isDarkMode ? 'bg-red-950/50 text-red-400 border-2 border-red-500/30' : 'bg-red-100 text-red-800 border-2 border-slate-900 shadow-[2px_2px_0px_#1e293b]',
    tosTitleInfo: isDarkMode ? 'bg-sky-950/50 text-sky-400 border-2 border-sky-500/30' : 'bg-sky-100 text-sky-800 border-2 border-slate-900 shadow-[2px_2px_0px_#1e293b]',
    footerIcon: isDarkMode ? 'border-slate-800 bg-slate-900 text-slate-400 hover:text-amber-500 hover:border-amber-500' : 'border-slate-300 bg-transparent text-slate-600 hover:text-amber-600 hover:border-amber-400'
  };

  useEffect(() => {
    const timer = setInterval(() => {
      setHeroBgIndex((prev) => (prev + 1) % heroBgImages.length);
    }, 4500);
    return () => clearInterval(timer);
  }, []);

  const tLang = t[language as keyof typeof t];
  const formatPrice = (priceStr: string) => {
    // Handle '30+' or '+$15' cases
    const isAddon = priceStr.startsWith('+');
    const isPlus = priceStr.endsWith('+');
    const numericPart = parseFloat(priceStr.replace(/[^0-9.]/g, ''));
    
    if (isNaN(numericPart)) return priceStr;

    if (currency === 'BRL') {
        return (isAddon ? '+' : '') + `R$${numericPart.toFixed(0)}` + (isPlus ? '+' : '');
    } else {
        const usd = numericPart / exchangeRate;
        return (isAddon ? '+' : '') + `$${usd.toFixed(0)}` + (isPlus ? '+' : '');
    }
  };

  const portfolioItems = activePortfolioTab === 'all' 
      ? [...artItems, ...videoItems]
      : (activePortfolioTab === 'video' ? videoItems : (activePortfolioTab === 'nsfw' ? nsfwItems : artItems));

  const handleNsfwClick = (e: React.MouseEvent<HTMLAnchorElement>, url: string) => {
    e.preventDefault();
    setNsfwTargetUrl(url);
    setNsfwDialogOpen(true);
  };

  const handlePortfolioTabClick = (tabId: string) => {
    if (tabId === 'nsfw' && !showNsfwPortfolio) {
        setNsfwTargetUrl('tab');
        setNsfwDialogOpen(true);
    } else {
        setActivePortfolioTab(tabId as 'all' | 'video' | 'nsfw');
    }
  };

  const confirmNsfw = () => {
      setNsfwDialogOpen(false);
      if (nsfwTargetUrl === 'tab') {
          setShowNsfwPortfolio(true);
          setActivePortfolioTab('nsfw');
      } else if (nsfwTargetUrl) {
          window.open(nsfwTargetUrl, '_blank', 'noopener,noreferrer');
      }
      setNsfwTargetUrl('');
  };

  return (
    <div className={`min-h-screen font-sans relative transition-colors duration-500 ${theme.bg}`}>
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
      
      <main className="relative z-10 w-full h-full">
        {/* Navigation */}
        <nav className={`fixed w-full top-0 z-50 backdrop-blur-xl border-b shadow-sm transition-colors duration-500 ${theme.navBg}`}>
          <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-center relative">
            
            <div className="hidden md:flex items-center gap-8 text-sm font-semibold transition-colors duration-500">
              <a href="#home" className={`transition-colors ${theme.navLink}`}>{tLang.nav.home}</a>
              <a href="#portfolio" className={`transition-colors ${theme.navLink}`}>{tLang.nav.portfolio}</a>
              <a href="#pricing" className={`transition-colors ${theme.navLink}`}>{tLang.nav.services}</a>
              <a href="#tos" className={`transition-colors ${theme.navLink}`}>{tLang.nav.terms}</a>
              
              {/* Improved Language Switcher */}
              <div className={`relative flex items-center p-1 rounded-full border-2 ml-4 ${
                  isDarkMode 
                    ? 'bg-slate-900 border-slate-800' 
                    : 'bg-white border-slate-900/10 shadow-sm'
              }`}>
                <button
                  onClick={() => {
                    setLanguage('PT');
                    setCurrency('BRL');
                  }}
                  className={`relative px-4 py-1.5 text-xs font-bold rounded-full transition-colors duration-200 z-10 flex items-center gap-1.5 ${
                    language === 'PT'
                      ? 'text-slate-950 font-black'
                      : isDarkMode ? 'text-slate-400 hover:text-slate-200' : 'text-slate-600 hover:text-slate-905'
                  }`}
                >
                  {language === 'PT' && (
                    <motion.span
                      layoutId="activeLangDesktop"
                      className="absolute inset-0 bg-amber-400 rounded-full z-[-1] border-2 border-slate-900 shadow-sm"
                      transition={{ type: "spring", stiffness: 400, damping: 25 }}
                    />
                  )}
                  <span>🇧🇷</span>
                  <span>PT-BR</span>
                </button>
                <button
                  onClick={() => {
                    setLanguage('EN');
                    setCurrency('USD');
                  }}
                  className={`relative px-4 py-1.5 text-xs font-bold rounded-full transition-colors duration-200 z-10 flex items-center gap-1.5 ${
                    language === 'EN'
                      ? 'text-slate-950 font-black'
                      : isDarkMode ? 'text-slate-400 hover:text-slate-200' : 'text-slate-600 hover:text-slate-905'
                  }`}
                >
                  {language === 'EN' && (
                    <motion.span
                      layoutId="activeLangDesktop"
                      className="absolute inset-0 bg-amber-400 rounded-full z-[-1] border-2 border-slate-900 shadow-sm"
                      transition={{ type: "spring", stiffness: 400, damping: 25 }}
                    />
                  )}
                  <span>🇬🇧</span>
                  <span>EN</span>
                </button>
              </div>

              <button
                onClick={() => setIsDarkMode(!isDarkMode)}
                className={`p-2 rounded-full transition-colors ml-2 ${theme.navLink}`}
                aria-label={isDarkMode ? "Ativar tema claro" : "Ativar tema escuro"}
              >
                {isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
              </button>
            </div>

            <div className="md:hidden absolute right-6 flex items-center gap-2">
              <button
                onClick={() => setIsDarkMode(!isDarkMode)}
                className={`p-2 rounded-full transition-colors ${theme.navLink}`}
                aria-label={isDarkMode ? "Ativar tema claro" : "Ativar tema escuro"}
              >
                {isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
              </button>
              <button 
                className={`p-2 transition-colors ${theme.navLink}`}
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                aria-label={isMobileMenuOpen ? "Fechar menu" : "Abrir menu"}
              >
                {isMobileMenuOpen ? <X /> : <Menu />}
              </button>
            </div>
          </div>

          {/* Mobile menu */}
          <AnimatePresence>
            {isMobileMenuOpen && (
              <motion.div 
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="md:hidden border-b border-white bg-white/90 backdrop-blur-xl overflow-hidden"
              >
                <div className={`flex flex-col px-6 py-4 gap-4 pb-8 font-semibold transition-colors duration-500 ${theme.mobileNavBg}`}>
                  <a href="#home" onClick={() => setIsMobileMenuOpen(false)} className={`py-2 w-fit ${theme.navLink}`}>{tLang.nav.home}</a>
                  <a href="#portfolio" onClick={() => setIsMobileMenuOpen(false)} className={`py-2 w-fit ${theme.navLink}`}>{tLang.nav.portfolio}</a>
                  <a href="#pricing" onClick={() => setIsMobileMenuOpen(false)} className={`py-2 w-fit ${theme.navLink}`}>{tLang.nav.services}</a>
                  <a href="#tos" onClick={() => setIsMobileMenuOpen(false)} className={`py-2 w-fit ${theme.navLink}`}>{tLang.nav.terms}</a>
                  <div className="py-2 border-t border-slate-900/10 dark:border-white/10 mt-2">
                    <p className={`text-xs uppercase tracking-wider mb-2 opacity-60 ${isDarkMode ? 'text-slate-400' : 'text-slate-600'}`}>Idioma / Language</p>
                    <div className={`relative flex items-center p-1 rounded-full border-2 w-fit ${
                        isDarkMode 
                          ? 'bg-slate-900 border-slate-800' 
                          : 'bg-white border-slate-900/10 shadow-sm'
                    }`}>
                      <button
                        onClick={() => {
                          setLanguage('PT');
                          setCurrency('BRL');
                          setIsMobileMenuOpen(false);
                        }}
                        className={`relative px-4 py-1.5 text-xs font-bold rounded-full transition-colors duration-200 z-10 flex items-center gap-1.5 ${
                          language === 'PT'
                            ? 'text-slate-950 font-black'
                            : isDarkMode ? 'text-slate-400 hover:text-slate-200' : 'text-slate-600 hover:text-slate-905'
                        }`}
                      >
                        {language === 'PT' && (
                          <motion.span
                            layoutId="activeLangMobile"
                            className="absolute inset-0 bg-amber-400 rounded-full z-[-1] border-2 border-slate-900 shadow-sm"
                            transition={{ type: "spring", stiffness: 400, damping: 25 }}
                          />
                        )}
                        <span>🇧🇷</span>
                        <span>PT-BR</span>
                      </button>
                      <button
                        onClick={() => {
                          setLanguage('EN');
                          setCurrency('USD');
                          setIsMobileMenuOpen(false);
                        }}
                        className={`relative px-4 py-1.5 text-xs font-bold rounded-full transition-colors duration-200 z-10 flex items-center gap-1.5 ${
                          language === 'EN'
                            ? 'text-slate-950 font-black'
                            : isDarkMode ? 'text-slate-400 hover:text-slate-200' : 'text-slate-600 hover:text-slate-905'
                        }`}
                      >
                        {language === 'EN' && (
                          <motion.span
                            layoutId="activeLangMobile"
                            className="absolute inset-0 bg-amber-400 rounded-full z-[-1] border-2 border-slate-900 shadow-sm"
                            transition={{ type: "spring", stiffness: 400, damping: 25 }}
                          />
                        )}
                        <span>🇬🇧</span>
                        <span>EN</span>
                      </button>
                    </div>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </nav>

        {/* Hero Section */}
        <section id="home" className="relative pt-32 pb-12 px-6 min-h-[70vh] flex flex-col justify-center overflow-hidden">
          {/* Background Carousel */}
          <div className="absolute inset-0 z-0 overflow-hidden select-none pointer-events-none">
            <AnimatePresence mode="popLayout">
              <motion.img
                key={heroBgIndex}
                src={heroBgImages[heroBgIndex]}
                alt="Artist artwork theme background"
                referrerPolicy="no-referrer"
                initial={{ opacity: 0, scale: 1.05 }}
                animate={{ opacity: 0.25, scale: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 1.5, ease: "easeInOut" }}
                className="w-full h-full object-cover filter blur-[2px]"
              />
            </AnimatePresence>
            {/* Smooth overlay layers to retain high text visibility */}
            <div className={`absolute inset-0 bg-gradient-to-t ${isDarkMode ? 'from-slate-950 via-slate-950/60' : 'from-slate-50 via-slate-50/45'} to-transparent transition-colors duration-500`}></div>
            <div className={`absolute inset-0 bg-gradient-to-r ${isDarkMode ? 'from-slate-950/60 via-transparent to-slate-950/60' : 'from-slate-50/20 via-transparent to-slate-50/20'} transition-colors duration-500`}></div>
          </div>

          <div className="max-w-4xl mx-auto text-center relative z-10">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className={`inline-flex items-center gap-2 px-5 py-2.5 rounded-full border shadow-sm backdrop-blur-md text-sm font-bold mb-8 transition-colors duration-500 ${theme.heroBadge}`}
            >
              <span className="w-2.5 h-2.5 rounded-full bg-yellow-500 animate-pulse" />
              {tLang.hero.status}
            </motion.div>
            
            <motion.h1 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className={`text-5xl md:text-7xl font-extrabold tracking-tight leading-tight mb-6 transition-colors duration-500 ${theme.heading}`}
            >
              {tLang.hero.title1} <br />
              <span className="bg-gradient-to-r from-amber-600 via-orange-500 to-yellow-500 bg-clip-text text-transparent drop-shadow-sm">
                {tLang.hero.title2}
              </span>
            </motion.h1>
            
            <motion.p 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className={`text-lg md:text-xl mb-6 max-w-2xl mx-auto leading-relaxed font-medium transition-colors duration-500 ${theme.subheading}`}
            >
              {tLang.hero.desc}
            </motion.p>

            {/* Social Media Links under Description */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.25 }}
              className="flex items-center justify-center gap-3 mb-10 mx-auto"
            >
              <a href="https://x.com/TheMakasan" target="_blank" rel="noopener noreferrer" title="Twitter" className={`p-2.5 border-2 rounded-xl transition-all shadow-sm hover:shadow-md backdrop-blur-sm flex items-center justify-center ${theme.socialBtn}`}>
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4l11.733 16h4.267l-11.733 -16z"/><path d="M4 20l6.768 -6.768m2.46 -2.46l6.772 -6.772"/></svg>
              </a>
              <a href="https://x.com/TheMakasanNSFW" onClick={(e) => handleNsfwClick(e, 'https://x.com/TheMakasanNSFW')} title="Twitter NSFW" className={`p-2.5 border-2 rounded-xl transition-all shadow-sm hover:shadow-md backdrop-blur-sm relative overflow-hidden flex items-center justify-center ${theme.socialBtn}`}>
                <div className="absolute inset-x-0 bottom-0 top-0 opacity-10 bg-red-500 rounded-lg pointer-events-none"></div>
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-red-500"><path d="M4 4l11.733 16h4.267l-11.733 -16z"/><path d="M4 20l6.768 -6.768m2.46 -2.46l6.772 -6.772"/></svg>
                <span className="sr-only">NSFW X/Twitter</span>
              </a>
              <a href="https://www.instagram.com/makasanart/?hl=pt" target="_blank" rel="noopener noreferrer" title="Instagram" className={`p-2.5 border-2 rounded-xl transition-all shadow-sm hover:shadow-md backdrop-blur-sm flex items-center justify-center ${theme.socialBtn}`}>
                <Instagram className="w-5 h-5" />
              </a>
              <a href="https://www.tiktok.com/@themakasan" target="_blank" rel="noopener noreferrer" title="TikTok" className={`p-2.5 border-2 rounded-xl transition-all shadow-sm hover:shadow-md backdrop-blur-sm flex items-center justify-center ${theme.socialBtn}`}>
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 448 512" fill="currentColor"><path d="M448,209.91a210.06,210.06,0,0,1-122.77-39.25V349.38A162.55,162.55,0,1,1,185,188.31V278.2a74.62,74.62,0,1,0,52.23,71.18V0l88,0a121.18,121.18,0,0,0,1.86,22.17h0A122.18,122.18,0,0,0,381,102.39a121.43,121.43,0,0,0,67,20.14Z"/></svg>
              </a>
            </motion.div>
            
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.35 }}
              className="flex flex-col sm:flex-row items-center justify-center gap-4"
            >
              <a href="#pricing" className="w-full sm:w-auto px-8 py-4 rounded-xl bg-gradient-to-r from-amber-500 to-orange-600 hover:from-amber-600 hover:to-orange-700 text-white font-bold transition-all shadow-md hover:shadow-lg hover:shadow-amber-500/20">
                {tLang.hero.btn1}
              </a>
              <a href="#portfolio" className={`w-full sm:w-auto px-8 py-4 rounded-xl border-2 font-bold transition-all shadow-sm ${theme.secondaryBtn}`}>
                {tLang.hero.btn2}
              </a>
            </motion.div>


          </div>
        </section>

        {/* Portfolio Grid Section */}
        <motion.section 
          id="portfolio" 
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className={`py-16 px-6 backdrop-blur-xl border-y transition-colors duration-500 ${theme.sectionBg}`}
        >
          <div className="max-w-7xl mx-auto">
            <div className="mb-16 flex flex-col md:flex-row items-center justify-between gap-8 text-center md:text-left">
              <div>
                <h2 className={`text-3xl md:text-5xl font-extrabold mb-4 tracking-tight transition-colors duration-500 ${theme.heading}`}>{tLang.portfolio.title}</h2>
                <p className={`max-w-xl font-medium text-lg mx-auto md:mx-0 transition-colors duration-500 ${theme.subheading}`}>{tLang.portfolio.desc}</p>
              </div>

              {/* Portfolio Tabs */}
              <div className={`flex flex-wrap justify-center gap-2 p-1.5 backdrop-blur-md rounded-2xl shadow-sm border w-fit shrink-0 transition-colors duration-500 ${theme.tabWrapper}`}>
                {tLang.portfolio.tabs.map((tab) => (
                  <button
                    key={tab.id}
                    onClick={() => handlePortfolioTabClick(tab.id)}
                    className={`flex items-center px-6 py-3 rounded-xl text-sm font-bold transition-all ${
                      activePortfolioTab === tab.id 
                        ? 'bg-amber-500 text-slate-950 shadow-md shadow-amber-500/20' 
                        : theme.tabDefault
                    }`}
                  >
                    {tab.label}
                  </button>
                ))}
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 auto-rows-[300px] grid-flow-dense">
              {portfolioItems.map((item, i) => (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: i * 0.1 }}
                  key={item.color + activePortfolioTab}
                  className={`group relative rounded-3xl overflow-hidden border-2 shadow-sm transition-all cursor-pointer ${theme.card} bg-gradient-to-br ${item.color} ${item.double ? 'md:col-span-2 lg:col-span-2' : ''} hover:shadow-xl`}
                >
                  <div className={`absolute inset-0 flex items-center justify-center opacity-80 group-hover:opacity-100 transition-all duration-500 ${item.iconColor}`}>
                    {item.mediaUrl ? (
                      item.type === 'video' ? (
                        (() => {
                          const getYouTubeId = (url: string) => {
                            const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
                            const match = url.match(regExp);
                            return (match && match[2].length === 11) ? match[2] : null;
                          };
                          const getTikTokId = (url: string) => {
                            const match = url.match(/tiktok\.com\/.*video\/(\d+)/);
                            return match ? match[1] : null;
                          };
                          
                          const ytId = getYouTubeId(item.mediaUrl);
                          const tkId = getTikTokId(item.mediaUrl);
                          
                          if (ytId) {
                            return (
                              <iframe 
                                src={`https://www.youtube.com/embed/${ytId}?autoplay=1&mute=1&loop=1&playlist=${ytId}&controls=0&showinfo=0&rel=0`}
                                title="YouTube video player" 
                                frameBorder="0" 
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" 
                                className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500 pointer-events-none"
                              ></iframe>
                            );
                          } else if (tkId) {
                            return (
                              <iframe 
                                src={`https://www.tiktok.com/embed/v2/${tkId}`}
                                title="TikTok video player"
                                frameBorder="0"
                                allow="encrypted-media"
                                className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                              ></iframe>
                            );
                          } else {
                            return (
                              <video src={item.mediaUrl} autoPlay loop muted playsInline className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                            );
                          }
                        })()
                      ) : (
                        <img src={item.mediaUrl} alt="Portfolio item" className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                      )
                    ) : (
                      <div className="group-hover:scale-110 transition-transform duration-500">{item.icon}</div>
                    )}
                  </div>
                  <div className="absolute bottom-4 left-4 right-4 flex justify-between items-end opacity-0 group-hover:opacity-100 transition-all duration-300 translate-y-4 group-hover:translate-y-0">
                    <div className={`backdrop-blur-md px-4 py-2 rounded-xl text-sm font-bold shadow-sm transition-colors duration-500 ${theme.heroBadge}`}>
                      {item.type === 'image' ? tLang.portfolio.typeImage : tLang.portfolio.typeVideo}
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>
        </motion.section>

        {/* Pricing / Services Section */}
        <motion.section 
          id="pricing" 
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="py-16 px-6"
        >
          <div className="max-w-7xl mx-auto">
            <div className="text-center mb-16">
              <h2 className={`text-3xl md:text-5xl font-extrabold mb-6 tracking-tight transition-colors duration-500 ${theme.heading}`}>{tLang.pricing.title}</h2>
              <p className={`max-w-2xl mx-auto font-medium text-lg transition-colors duration-500 ${theme.subheading}`}>{tLang.pricing.desc}</p>
            </div>

            {/* Custom Tabs */}
            <div className={`flex flex-wrap justify-center gap-2 mb-12 p-1.5 backdrop-blur-md border shadow-sm rounded-2xl w-fit mx-auto transition-colors duration-500 ${theme.tabWrapper}`}>
              {tLang.pricing.tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id as any)}
                  className={`flex items-center px-6 py-3 rounded-xl text-sm font-bold transition-all ${
                    activeTab === tab.id 
                      ? 'bg-amber-500 text-slate-950 shadow-md shadow-amber-500/20' 
                      : theme.tabDefault
                  }`}
                >
                  {tab.id === 'digital' ? <Palette className="w-4 h-4 mr-2" /> : tab.id === 'special' ? <Sparkles className="w-4 h-4 mr-2" /> : <Video className="w-4 h-4 mr-2" />}
                  {tab.label}
                </button>
              ))}
            </div>

            {/* Pricing Cards Grid */}
            <div className={`grid grid-cols-1 ${tLang.pricingPlans[activeTab].length === 1 ? 'md:grid-cols-1 max-w-sm' : tLang.pricingPlans[activeTab].length === 2 ? 'md:grid-cols-2 max-w-3xl' : 'md:grid-cols-3 max-w-5xl'} gap-8 mx-auto`}>
              <AnimatePresence mode="wait">
                {tLang.pricingPlans[activeTab].map((plan, i) => {
                  const planKey = `${activeTab}-${i}`;
                  const totalPrice = calculatePlanTotal(plan, planKey);
                  return (
                    <motion.div
                      key={planKey}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -20 }}
                      transition={{ duration: 0.3, delay: i * 0.1 }}
                      className={`relative flex flex-col p-8 rounded-xl border-4 hover:-translate-y-2 transition-all duration-500 hover:shadow-[12px_12px_0px_#1e293b] ${theme.pricingCard} ${
                        plan.popular 
                          ? 'z-10 scale-105 -rotate-2' 
                          : 'rotate-1'
                      }`}
                    >
                      {/* Sticky Tape */}
                      <div className="absolute -top-5 left-1/2 -translate-x-1/2 z-20" style={{ transform: i % 2 === 0 ? 'rotate(-6deg)' : 'rotate(4deg)' }}>
                        <svg width="120" height="40" viewBox="0 0 120 40" fill="none" className="drop-shadow-[2px_3px_0px_rgba(15,23,42,1)]" xmlns="http://www.w3.org/2000/svg">
                          <path d="M 10 4 L 110 4 L 117 9 L 109 15 L 119 22 L 111 28 L 116 36 L 6 36 L 2 28 L 10 21 L 1 13 L 8 7 Z" fill={theme.tapeFill} stroke={isDarkMode ? '#020617' : '#0f172a'} strokeWidth="3" strokeLinejoin="round" className="transition-colors duration-500" />
                        </svg>
                      </div>

                      {plan.popular && (
                        <div className={`absolute -top-4 -right-4 bg-red-500 border-4 text-white text-xs font-black px-4 py-2 uppercase tracking-wider rotate-[15deg] z-30 transition-colors duration-500 ${isDarkMode ? 'border-slate-800 shadow-[4px_4px_0px_#020617]' : 'border-slate-900 shadow-[4px_4px_0px_#1e293b]'}`}>
                          {tLang.pricing.popular}
                        </div>
                      )}
                      
                      <div className="mb-8 mt-2">
                        <h3 className={`text-2xl font-black mb-2 uppercase tracking-widest transition-colors duration-500 ${theme.heading}`}>{plan.title}</h3>
                        {plan.desc && <p className={`text-sm mb-4 font-bold border-l-4 border-amber-500 pl-3 transition-colors duration-500 ${theme.subheading}`}>{plan.desc}</p>}
                        <div className="flex items-baseline gap-1 mt-6">
                          <span className={`text-5xl font-black transition-colors duration-500 ${theme.heading}`}>
                            {formatPrice(totalPrice.toString())}
                          </span>
                          {!isNaN(parseFloat(plan.price.replace(/[^0-9.]/g, ''))) && (
                            <span className={`font-black text-xl transition-colors duration-500 ${theme.heading}`}>{currency}</span>
                          )}
                        </div>
                      </div>

                      <div className="flex-1">
                        <p className={`text-sm border-b-4 pb-3 mb-4 font-black uppercase tracking-wider transition-colors duration-500 ${isDarkMode ? 'border-amber-500/30 text-amber-500' : 'border-slate-900 text-slate-700'}`}>
                          {tLang.pricing.addons}
                        </p>
                        <ul className="space-y-4">
                          {plan.addons.map((addon, idx) => {
                            const isSelected = (selectedAddons[planKey] || []).includes(addon.name);
                            const hasPrice = addon.price && addon.price !== '';
                            
                            return (
                              <li 
                                key={idx} 
                                onClick={() => hasPrice && toggleAddon(planKey, addon.name)}
                                className={`flex justify-between items-center text-sm font-bold group cursor-pointer p-1 -m-1 rounded-lg transition-colors ${hasPrice ? 'hover:bg-slate-900/5 dark:hover:bg-white/5' : 'cursor-default'}`}
                              >
                                <div className="flex items-center gap-3">
                                  {hasPrice && (
                                    <div className={`w-5 h-5 rounded border-2 transition-all flex items-center justify-center ${
                                      isSelected 
                                        ? 'bg-amber-400 border-slate-900 shadow-[2px_2px_0px_#1e293b]' 
                                        : 'bg-white border-slate-300 group-hover:border-slate-900 dark:bg-slate-800 dark:border-slate-700 dark:group-hover:border-amber-400'
                                    }`}>
                                      {isSelected && <div className="w-2.5 h-2.5 bg-slate-950 rounded-sm" />}
                                    </div>
                                  )}
                                  <span className={`transition-colors duration-500 ${isSelected ? 'text-amber-600 font-black' : theme.addonLabel}`}>{addon.name}</span>
                                </div>
                                {hasPrice && (
                                  <span className={`font-black font-mono text-xs border-2 px-2 py-1 transition-colors duration-500 ${isSelected ? 'bg-amber-400 border-slate-900 text-slate-900 shadow-[2px_2px_0px_#1e293b]' : theme.addonPrice}`}>
                                    {formatPrice(addon.price)}
                                  </span>
                                )}
                              </li>
                            );
                          })}
                        </ul>
                      </div>

                      <button 
                        onClick={() => handleSelectPlan(plan, planKey, totalPrice)}
                        className={`mt-8 w-full py-3.5 text-center font-black uppercase tracking-widest transition-all border-4 hover:-translate-y-1 active:translate-y-1 ${
                          plan.popular 
                            ? theme.pricingSelectPopular 
                            : theme.pricingSelectBase
                        }`}
                      >
                        {tLang.pricing.select}
                      </button>
                    </motion.div>
                  );
                })}
              </AnimatePresence>
            </div>
          </div>
        </motion.section>

        {/* Rules / TOS Section */}
        <motion.section 
          id="tos" 
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className={`py-16 px-6 backdrop-blur-xl border-y transition-colors duration-500 ${theme.sectionBg}`}
        >
          <div className="max-w-5xl mx-auto">
            <div className="text-center mb-16">
              <h2 className={`text-3xl md:text-5xl font-extrabold mb-4 tracking-tight transition-colors duration-500 ${theme.heading}`}>{tLang.tos.title}</h2>
              <p className={`font-medium text-lg transition-colors duration-500 ${theme.subheading}`}>{tLang.tos.subtitle}</p>
            </div>

            <div className="grid md:grid-cols-2 gap-8">
              <div className={`p-8 md:p-10 rounded-2xl transition-all duration-500 hover:-translate-y-2 ${theme.tosBoxGood}`}>
                <div className="flex items-center gap-3 mb-6">
                  <div className={`p-2 rounded-xl transition-colors duration-500 ${theme.tosTitleGood}`}>
                    <CheckCircle2 className="w-7 h-7" />
                  </div>
                  <h3 className={`text-2xl font-bold w-full tracking-tight transition-colors duration-500 ${theme.heading}`}>{tLang.tos.do}</h3>
                </div>
                <ul className={`space-y-4 font-medium transition-colors duration-500 ${theme.subheading}`}>
                  {tLang.tos.doList.map((item, idx) => (
                    <li key={idx} className="flex items-start gap-3">
                      <span className="mt-2 w-2 h-2 rounded-full bg-emerald-400 shrink-0" />
                      {item}
                    </li>
                  ))}
                </ul>
              </div>

              <div className={`p-8 md:p-10 rounded-2xl transition-all duration-500 hover:-translate-y-2 ${theme.tosBoxBad}`}>
                <div className="flex items-center gap-3 mb-6">
                  <div className={`p-2 rounded-xl transition-colors duration-500 ${theme.tosTitleBad}`}>
                    <XCircle className="w-7 h-7" />
                  </div>
                  <h3 className={`text-2xl font-bold tracking-tight transition-colors duration-500 ${theme.heading}`}>{tLang.tos.dont}</h3>
                </div>
                <ul className={`space-y-4 font-medium transition-colors duration-500 ${theme.subheading}`}>
                  {tLang.tos.dontList.map((item, idx) => (
                    <li key={idx} className="flex items-start gap-3">
                      <span className="mt-2 w-2 h-2 rounded-full bg-red-400 shrink-0" />
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            <div className="mt-12 space-y-8">
              <div className={`p-8 md:p-10 rounded-2xl transition-all duration-500 hover:-translate-y-2 ${theme.tosBoxInfo}`}>
                <div className="flex items-center gap-3 mb-6">
                  <div className={`p-2 rounded-xl transition-colors duration-500 ${theme.tosTitleInfo}`}>
                    <MessageSquare className="w-7 h-7" />
                  </div>
                  <h3 className={`text-2xl font-bold tracking-tight transition-colors duration-500 ${theme.heading}`}>{tLang.tos.howToOrder.title}</h3>
                </div>
                
                <div className="space-y-6">
                  <div>
                    <h4 className={`font-semibold mb-2 ${theme.heading}`}>{tLang.tos.howToOrder.methodsLabel}</h4>
                    <p className={`font-medium ${theme.subheading}`}>{tLang.tos.howToOrder.methods}</p>
                  </div>
                  <div>
                    <h4 className={`font-semibold mb-2 ${theme.heading}`}>{tLang.tos.howToOrder.infoLabel}</h4>
                    <p className={`font-medium ${theme.subheading}`}>{tLang.tos.howToOrder.info}</p>
                  </div>
                </div>
              </div>

              <div className={`p-8 md:p-10 rounded-2xl transition-all duration-500 hover:-translate-y-2 ${theme.tosBoxInfo}`}>
                <div className="flex items-center gap-3 mb-6">
                  <div className={`p-2 rounded-xl transition-colors duration-500 ${theme.tosTitleInfo}`}>
                    <FileText className="w-7 h-7" />
                  </div>
                  <h3 className={`text-2xl font-bold tracking-tight transition-colors duration-500 ${theme.heading}`}>{tLang.tos.terms.title}</h3>
                </div>
                
                <ul className={`space-y-4 font-medium transition-colors duration-500 ${theme.subheading}`}>
                  {tLang.tos.terms.list.map((item, idx) => (
                    <li key={idx} className="flex items-start gap-3">
                      <span className="mt-2.5 w-2 h-2 rounded-full bg-sky-400 shrink-0" />
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        </motion.section>

        {/* Footer */}
        <footer className={`py-10 px-6 border-t font-medium text-center text-sm flex flex-col items-center gap-6 transition-colors duration-500 ${isDarkMode ? 'border-slate-800 text-slate-500' : 'border-white/50 text-slate-500'}`}>
          <div className="flex items-center justify-center gap-3">
            <a href="https://x.com/TheMakasan" target="_blank" rel="noopener noreferrer" title="Twitter" className={`p-2.5 border-2 rounded-xl transition-all flex items-center justify-center ${theme.footerIcon}`}>
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4l11.733 16h4.267l-11.733 -16z"/><path d="M4 20l6.768 -6.768m2.46 -2.46l6.772 -6.772"/></svg>
            </a>
            <a href="https://x.com/TheMakasanNSFW" onClick={(e) => handleNsfwClick(e, 'https://x.com/TheMakasanNSFW')} title="Twitter NSFW" className={`p-2.5 border-2 rounded-xl transition-all relative overflow-hidden flex items-center justify-center ${theme.footerIcon}`}>
              <div className="absolute inset-x-0 bottom-0 top-0 opacity-10 bg-red-500 rounded-lg pointer-events-none"></div>
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-red-500"><path d="M4 4l11.733 16h4.267l-11.733 -16z"/><path d="M4 20l6.768 -6.768m2.46 -2.46l6.772 -6.772"/></svg>
            </a>
            <a href="https://www.instagram.com/makasanart/?hl=pt" target="_blank" rel="noopener noreferrer" title="Instagram" className={`p-2.5 border-2 rounded-xl transition-all flex items-center justify-center ${theme.footerIcon}`}>
              <Instagram className="w-5 h-5" />
            </a>
            <a href="https://www.tiktok.com/@themakasan" target="_blank" rel="noopener noreferrer" title="TikTok" className={`p-2.5 border-2 rounded-xl transition-all flex items-center justify-center ${theme.footerIcon}`}>
               <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 448 512" fill="currentColor"><path d="M448,209.91a210.06,210.06,0,0,1-122.77-39.25V349.38A162.55,162.55,0,1,1,185,188.31V278.2a74.62,74.62,0,1,0,52.23,71.18V0l88,0a121.18,121.18,0,0,0,1.86,22.17h0A122.18,122.18,0,0,0,381,102.39a121.43,121.43,0,0,0,67,20.14Z"/></svg>
            </a>
          </div>
          <p>&copy; {new Date().getFullYear()} {tLang.footer}</p>
        </footer>
      </main>

      {/* NSFW Modal */}
      <AnimatePresence>
        {nsfwDialogOpen && (
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
              <div className="mx-auto w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mb-6">
                 <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-red-600">
                    <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                    <line x1="12" y1="9" x2="12" y2="13"/>
                    <line x1="12" y1="17" x2="12.01" y2="17"/>
                 </svg>
              </div>
              <h3 className="text-2xl font-bold text-center mb-4">{tLang.nsfwModal.title}</h3>
              <p className="text-center font-medium mb-8 opacity-80">
                {tLang.nsfwModal.message}
              </p>
              
              <div className="flex flex-col gap-3">
                <button
                  onClick={confirmNsfw}
                  className="w-full py-4 rounded-xl font-bold text-white bg-red-600 hover:bg-red-700 transition-colors"
                >
                  {tLang.nsfwModal.confirm}
                </button>
                <button
                  onClick={() => setNsfwDialogOpen(false)}
                  className={`w-full py-4 rounded-xl font-bold border-2 transition-colors ${isDarkMode ? 'border-slate-700 hover:bg-slate-800' : 'border-slate-200 hover:bg-slate-50'}`}
                >
                  {tLang.nsfwModal.cancel}
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Toast Notification */}
      <AnimatePresence>
        {showToast && (
          <motion.div
            initial={{ opacity: 0, y: 50, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 50, scale: 0.9 }}
            className={`fixed bottom-6 right-6 z-[200] max-w-sm w-full p-4 rounded-xl border-2 shadow-[8px_8px_0px_#1e293b] flex items-start gap-4 ${isDarkMode ? 'bg-slate-800 border-slate-700 text-slate-200' : 'bg-white border-slate-900 text-slate-800'}`}
          >
            <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center flex-shrink-0">
              <CheckCircle2 className="w-6 h-6 text-emerald-600" />
            </div>
            <div className="flex-1 pt-1">
              <p className="font-bold text-sm whitespace-pre-line">{toastMessage}</p>
            </div>
            <button onClick={() => setShowToast(false)} className="text-slate-400 hover:text-slate-600">
              <XCircle className="w-5 h-5" />
            </button>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
