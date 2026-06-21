import React from 'react';
import { Instagram } from 'lucide-react';
import { ThemeColors } from '../../types';
import { socialItems, SocialItem } from '../../data';

interface FooterProps {
  theme: ThemeColors;
  t: any;
  isDarkMode: boolean;
  handleNsfwClick: (e: React.MouseEvent<HTMLAnchorElement>, url: string) => void;
}

export function Footer({ theme, t, isDarkMode, handleNsfwClick }: FooterProps) {
  const getSocialIcon = (platform: SocialItem['platform'], isNsfw?: boolean) => {
    switch (platform) {
      case 'twitter':
        return <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={isNsfw ? "text-red-500" : ""}><path d="M4 4l11.733 16h4.267l-11.733 -16z"/><path d="M4 20l6.768 -6.768m2.46 -2.46l6.772 -6.772"/></svg>;
      case 'instagram':
        return <Instagram className="w-5 h-5" />;
      case 'tiktok':
        return <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 448 512" fill="currentColor"><path d="M448,209.91a210.06,210.06,0,0,1-122.77-39.25V349.38A162.55,162.55,0,1,1,185,188.31V278.2a74.62,74.62,0,1,0,52.23,71.18V0l88,0a121.18,121.18,0,0,0,1.86,22.17h0A122.18,122.18,0,0,0,381,102.39a121.43,121.43,0,0,0,67,20.14Z"/></svg>;
      case 'youtube':
        return <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/></svg>;
      default:
        return <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>;
    }
  };

  return (
    <footer className={`py-10 px-6 border-t font-medium text-center text-sm flex flex-col items-center gap-6 transition-colors duration-500 ${isDarkMode ? 'border-slate-800 text-slate-500' : 'border-white/50 text-slate-500'}`}>
      <div className="flex items-center justify-center gap-3">
        {socialItems.map((item, idx) => {
          if (item.nsfw) {
            return (
              <a key={idx} href={item.url} onClick={(e) => handleNsfwClick(e, item.url)} title={`${item.platform} NSFW`} className={`p-2.5 border-2 rounded-xl transition-all relative overflow-hidden flex items-center justify-center ${theme.footerIcon}`}>
                <div className="absolute inset-x-0 bottom-0 top-0 opacity-10 bg-red-500 rounded-lg pointer-events-none"></div>
                {getSocialIcon(item.platform, true)}
              </a>
            );
          }
          return (
            <a key={idx} href={item.url} target="_blank" rel="noopener noreferrer" title={item.platform} className={`p-2.5 border-2 rounded-xl transition-all flex items-center justify-center ${theme.footerIcon}`}>
              {getSocialIcon(item.platform)}
            </a>
          );
        })}
      </div>
      <p>&copy; {new Date().getFullYear()} {t.footer}</p>
    </footer>
  );
}