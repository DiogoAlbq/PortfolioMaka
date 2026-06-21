import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Instagram, Sparkles } from 'lucide-react';
import { ThemeColors, PortfolioItem } from '../../types';
import { socialItems, SocialItem } from '../../data';

interface HeroProps {
  theme: ThemeColors;
  t: any;
  heroBgImages: PortfolioItem[];
  heroBgIndex: number;
  isDarkMode: boolean;
  handleNsfwClick: (e: React.MouseEvent<HTMLAnchorElement>, url: string) => void;
}

export function Hero({ theme, t, heroBgImages, heroBgIndex, isDarkMode, handleNsfwClick }: HeroProps) {
  const getSocialIcon = (platform: SocialItem['platform'], isNsfw?: boolean) => {
    switch (platform) {
      case 'twitter':
        return <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={isNsfw ? "text-red-500" : ""}><path d="M4 4l11.733 16h4.267l-11.733 -16z" /><path d="M4 20l6.768 -6.768m2.46 -2.46l6.772 -6.772" /></svg>;
      case 'instagram':
        return <Instagram className="w-6 h-6" />;
      case 'tiktok':
        return <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 448 512" fill="currentColor"><path d="M448,209.91a210.06,210.06,0,0,1-122.77-39.25V349.38A162.55,162.55,0,1,1,185,188.31V278.2a74.62,74.62,0,1,0,52.23,71.18V0l88,0a121.18,121.18,0,0,0,1.86,22.17h0A122.18,122.18,0,0,0,381,102.39a121.43,121.43,0,0,0,67,20.14Z" /></svg>;
      case 'youtube':
        return <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" /></svg>;
      default:
        return <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10" /><line x1="2" y1="12" x2="22" y2="12" /><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" /></svg>;
    }
  };

  return (
    <section id="home" className="relative pt-32 pb-12 px-6 min-h-[80vh] flex flex-col justify-center overflow-hidden">
      <div className="absolute inset-0 z-0 overflow-hidden select-none pointer-events-none">
        <AnimatePresence mode="popLayout">
          {heroBgImages[heroBgIndex] && heroBgImages[heroBgIndex].mediaUrl && (
            <motion.img
              key={heroBgIndex}
              src={heroBgImages[heroBgIndex].mediaUrl}
              alt="Artist artwork theme background"
              referrerPolicy="no-referrer"
              initial={{ opacity: 0, scale: 1.05 }}
              animate={{ opacity: 0.18, scale: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 1.8, ease: 'easeInOut' }}
              className="w-full h-full object-cover filter blur-[1px]"
            />
          )}
        </AnimatePresence>
        <div className={`absolute inset-0 bg-gradient-to-t transition-colors duration-500 ${theme.overlayEnd} to-transparent`}></div>
        <div className={`absolute inset-0 bg-gradient-to-r transition-colors duration-500 ${theme.overlaySide}`}></div>
      </div>

      <div className="max-w-4xl mx-auto text-center relative z-10 px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className={`inline-flex items-center gap-2 px-5 py-2.5 rounded-full border shadow-sm backdrop-blur-md text-sm font-bold mb-8 transition-colors duration-500 ${theme.heroBadge}`}
        >
          <span className="w-2.5 h-2.5 rounded-full bg-yellow-500 animate-pulse" />
          {t.hero.status}
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className={`text-5xl md:text-7xl lg:text-8xl font-extrabold tracking-tight leading-tight mb-6 transition-colors duration-500 ${theme.heading}`}
        >
          {t.hero.title1} <br />
          <span className="bg-gradient-to-r from-amber-600 via-orange-500 to-yellow-500 bg-clip-text text-transparent drop-shadow-sm">
            {t.hero.title2}
          </span>
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className={`text-lg md:text-xl lg:text-2xl mb-8 max-w-3xl mx-auto leading-relaxed font-medium transition-colors duration-500 ${theme.subheading}`}
        >
          {t.hero.desc}
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.35 }}
          className="flex items-center justify-center gap-3 mb-10 mx-auto flex-wrap"
        >
          {socialItems.map((item, idx) => {
            if (item.nsfw) {
              return (
                <a key={idx} href={item.url} onClick={(e) => handleNsfwClick(e, item.url)} title={`${item.platform} NSFW`} className={`p-3 border-2 rounded-xl transition-all shadow-sm hover:shadow-md backdrop-blur-sm relative overflow-hidden flex items-center justify-center ${theme.socialBtn}`}>
                  <div className="absolute inset-x-0 bottom-0 top-0 opacity-10 bg-red-500 rounded-lg pointer-events-none"></div>
                  {getSocialIcon(item.platform, true)}
                  <span className="sr-only">NSFW {item.platform}</span>
                </a>
              );
            }
            return (
              <a key={idx} href={item.url} target="_blank" rel="noopener noreferrer" title={item.platform} className={`p-3 border-2 rounded-xl transition-all shadow-sm hover:shadow-md backdrop-blur-sm flex items-center justify-center ${theme.socialBtn}`}>
                {getSocialIcon(item.platform)}
              </a>
            );
          })}
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="flex flex-col sm:flex-row items-center justify-center gap-4"
        >
          <a href="#pricing" className="w-full sm:w-auto px-8 py-4 rounded-xl bg-gradient-to-r from-amber-500 to-orange-600 hover:from-amber-600 hover:to-orange-700 text-white font-bold transition-all shadow-md hover:shadow-lg hover:shadow-amber-500/20 text-lg">
            {t.hero.btn1}
          </a>
          <a href="#portfolio" className={`w-full sm:w-auto px-8 py-4 rounded-xl border-2 font-bold transition-all shadow-sm text-lg ${theme.secondaryBtn}`}>
            {t.hero.btn2}
          </a>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.5 }}
          className="mt-12 flex items-center justify-center gap-6 text-sm opacity-70"
        >
          <div className="flex items-center gap-2">
            <Sparkles className="w-5 h-5 text-amber-500" />
            <span className="font-medium">Comissões Abertas</span>
          </div>
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
            <span className="font-medium">Entrega em até 60 dias</span>
          </div>
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-sky-500" />
            <span className="font-medium">Pagamento via PayPal/Pix</span>
          </div>
        </motion.div>
      </div>
    </section>
  );
}