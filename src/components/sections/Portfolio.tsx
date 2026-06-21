import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ThemeColors, PortfolioItem, PortfolioTab } from '../../types';
import { getYouTubeId, getTikTokId } from '../../utils/media';

interface PortfolioProps {
  theme: ThemeColors;
  t: any;
  activeTab: PortfolioTab;
  setActiveTab: (tab: PortfolioTab) => void;
  portfolioItems: PortfolioItem[];
  showNsfwPortfolio: boolean;
  setShowNsfwPortfolio: (show: boolean) => void;
  nsfwTargetUrl: string;
  setNsfwTargetUrl: (url: string) => void;
  nsfwDialogOpen: boolean;
  setNsfwDialogOpen: (open: boolean) => void;
}

export function Portfolio({
  theme,
  t,
  activeTab,
  setActiveTab,
  portfolioItems,
  showNsfwPortfolio,
  setShowNsfwPortfolio,
  nsfwTargetUrl,
  setNsfwTargetUrl,
  nsfwDialogOpen,
  setNsfwDialogOpen,
}: PortfolioProps) {
  const handlePortfolioTabClick = (tabId: string) => {
    if (tabId === 'nsfw' && !showNsfwPortfolio) {
      setNsfwTargetUrl('tab');
      setNsfwDialogOpen(true);
    } else {
      setActiveTab(tabId as PortfolioTab);
    }
  };

  const handleNsfwClick = (e: React.MouseEvent<HTMLAnchorElement>, url: string) => {
    e.preventDefault();
    setNsfwTargetUrl(url);
    setNsfwDialogOpen(true);
  };

  return (
    <motion.section
      id="portfolio"
      initial={{ opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: '-100px' }}
      transition={{ duration: 0.6 }}
      className={`py-16 px-6 backdrop-blur-xl border-y transition-colors duration-500 ${theme.sectionBg}`}
    >
      <div className="max-w-7xl mx-auto">
        <div className="mb-16 flex flex-col md:flex-row items-center justify-between gap-8 text-center md:text-left">
          <div>
            <h2 className={`text-3xl md:text-5xl font-extrabold mb-4 tracking-tight transition-colors duration-500 ${theme.heading}`}>{t.portfolio.title}</h2>
            <p className={`max-w-xl font-medium text-lg mx-auto md:mx-0 transition-colors duration-500 ${theme.subheading}`}>{t.portfolio.desc}</p>
          </div>

          <div className={`flex flex-wrap justify-center gap-2 p-1.5 backdrop-blur-md rounded-2xl shadow-sm border w-fit shrink-0 transition-colors duration-500 ${theme.tabWrapper}`}>
            {t.portfolio.tabs.map((tab: { id: PortfolioTab; label: string }) => (
              <button
                key={tab.id}
                onClick={() => handlePortfolioTabClick(tab.id)}
                className={`flex items-center px-6 py-3 rounded-xl text-sm font-bold transition-all ${
                  activeTab === tab.id
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
              transition={{ delay: i * 0.08 }}
              key={`${item.color}-${i}-${activeTab}`}
              className={`group relative rounded-3xl overflow-hidden border-2 shadow-sm transition-all cursor-pointer ${theme.card} bg-gradient-to-br ${item.color} ${item.double ? 'md:col-span-2 lg:col-span-2' : ''} ${item.vertical ? 'md:row-span-2 lg:row-span-2' : ''} hover:shadow-xl`}
            >
              <div className={`absolute inset-0 flex items-center justify-center opacity-80 group-hover:opacity-100 transition-all duration-500 ${item.iconColor}`}>
                {item.mediaUrl ? (
                  item.type === 'video' ? (
                    (() => {
                      const ytId = getYouTubeId(item.mediaUrl!);
                      const tkId = getTikTokId(item.mediaUrl!);

                      if (ytId) {
                        return (
                          <iframe
                            src={`https://www.youtube.com/embed/${ytId}?autoplay=1&mute=1&loop=1&playlist=${ytId}&controls=1&rel=0&vq=hd720`}
                            title={`YouTube video player - item ${i + 1}`}
                            frameBorder="0"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share; fullscreen"
                            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                          />
                        );
                      } else if (tkId) {
                        return (
                          <iframe
                            src={`https://www.tiktok.com/embed/v2/${tkId}?autoplay=1&mute=1`}
                            title={`TikTok video player - item ${i + 1}`}
                            frameBorder="0"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share; fullscreen"
                            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                          />
                        );
                      } else {
                        return (
                          <video src={item.mediaUrl!} autoPlay loop muted controls playsInline className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                        );
                      }
                    })()
                  ) : (
                    <img src={item.mediaUrl!} alt={`Portfolio artwork ${i + 1}`} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                  )
                ) : (
                  <div className="group-hover:scale-110 transition-transform duration-500">{item.icon}</div>
                )}
              </div>
              <div className="absolute bottom-4 left-4 right-4 flex justify-between items-end opacity-0 group-hover:opacity-100 transition-all duration-300 translate-y-4 group-hover:translate-y-0">
                <div className={`backdrop-blur-md px-4 py-2 rounded-xl text-sm font-bold shadow-sm transition-colors duration-500 ${theme.heroBadge}`}>
                  {item.type === 'image' ? t.portfolio.typeImage : t.portfolio.typeVideo}
                </div>
                {item.mediaUrl && (
                  <a
                    href={item.mediaUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="backdrop-blur-md px-4 py-2 rounded-xl text-sm font-bold shadow-sm transition-colors duration-500 text-amber-600 hover:text-amber-400 dark:text-amber-400 dark:hover:text-amber-300"
                  >
                    Ver original
                  </a>
                )}
              </div>
            </motion.div>
          ))}
        </div>

        {portfolioItems.length === 0 && (
          <div className="text-center py-20">
            <div className="inline-flex items-center justify-center w-24 h-24 rounded-full bg-slate-100 dark:bg-slate-800 mb-6">
              <svg className="w-12 h-12 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth="1.5">
                <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 3.75v16.5a2.25 2.25 0 002.25 2.25h13.5A2.25 2.25 0 0021 20.25V3.75M3.75 3.75h16.5M18.75 3.75l-1.5 1.5m0 0l-3 3m3-3h-16.5" />
              </svg>
            </div>
            <h3 className={`text-xl font-bold mb-2 ${theme.heading}`}>Nenhuma mídia ainda</h3>
            <p className={`text-slate-500 dark:text-slate-400 max-w-md mx-auto`}>
              Adicione imagens ou vídeos no gerenciador de portfólio para exibi-las aqui.
            </p>
          </div>
        )}
      </div>
    </motion.section>
  );
}