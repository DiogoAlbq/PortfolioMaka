import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Palette, Sparkles, CheckCircle2, XCircle } from 'lucide-react';
import { ThemeColors, Plan, PlanAddon, Currency, PricingTab } from '../../types';
import { formatPrice } from '../../utils/theme.tsx';
import { Card, StickyTape, PopularBadge } from '../ui/Card';
import { Button } from '../ui/Button';

interface PricingProps {
  theme: ThemeColors;
  t: any;
  activeTab: PricingTab;
  setActiveTab: (tab: PricingTab) => void;
  pricingPlans: Record<PricingTab, Plan[]>;
  currency: Currency;
  selectedAddons: Record<string, string[]>;
  setSelectedAddons: React.Dispatch<React.SetStateAction<Record<string, string[]>>>;
  isDarkMode: boolean;
}

export function Pricing({
  theme,
  t,
  activeTab,
  setActiveTab,
  pricingPlans,
  currency,
  selectedAddons,
  setSelectedAddons,
  isDarkMode,
}: PricingProps) {
  const plans = pricingPlans[activeTab];
  const [toastMessage, setToastMessage] = useState('');
  const [showToast, setShowToast] = useState(false);

  const toggleAddon = (planKey: string, addonName: string) => {
    setSelectedAddons((prev) => {
      const current = prev[planKey] || [];
      const updated = current.includes(addonName)
        ? current.filter((name) => name !== addonName)
        : [...current, addonName];
      return { ...prev, [planKey]: updated };
    });
  };

  const calculatePlanTotal = (plan: Plan, planKey: string): number => {
    const basePrice = currency === 'BRL' ? plan.price_brl : plan.price_usd;
    const selected = selectedAddons[planKey] || [];

    const addonsTotal = selected.reduce((sum, addonName) => {
      const addon = plan.addons.find((a) => a.name === addonName);
      if (addon) {
        const addonPrice = currency === 'BRL' ? addon.price_brl : addon.price_usd;
        return sum + addonPrice;
      }
      return sum;
    }, 0);

    return (basePrice || 0) + addonsTotal;
  };

  const handleSelectPlan = async (plan: Plan, planKey: string, totalPrice: number) => {
    const selected = selectedAddons[planKey] || [];
    const tToast = t.toast;
    const basePrice = currency === 'BRL' ? plan.price_brl : plan.price_usd;

    const details = [
      tToast.greeting,
      `${tToast.plan}: ${plan.title}`,
      `${tToast.basePrice}: ${formatPrice(basePrice, currency)} ${currency}`,
      selected.length > 0 ? `${tToast.addons}: ${selected.join(', ')}` : null,
      `${tToast.total}: ${formatPrice(totalPrice, currency)} ${currency}`,
    ]
      .filter(Boolean)
      .join('\n');

    try {
      await navigator.clipboard.writeText(details);
      setToastMessage(tToast.success);
      setShowToast(true);
      setTimeout(() => setShowToast(false), 3000);
    } catch (err) {
      console.error('Failed to copy text: ', err);
      setToastMessage('Erro ao copiar. Tente novamente.');
      setShowToast(true);
      setTimeout(() => setShowToast(false), 3000);
    }
  };

  return (
    <motion.section
      id="pricing"
      initial={{ opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: '-100px' }}
      transition={{ duration: 0.6 }}
      className="py-16 px-6"
    >
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className={`text-3xl md:text-5xl font-extrabold mb-6 tracking-tight transition-colors duration-500 ${theme.heading}`}>{t.pricing.title}</h2>
          <p className={`max-w-2xl mx-auto font-medium text-lg transition-colors duration-500 ${theme.subheading}`}>{t.pricing.desc}</p>
        </div>

        <div className={`flex flex-wrap justify-center gap-2 mb-12 p-1.5 backdrop-blur-md border shadow-sm rounded-2xl w-fit mx-auto transition-colors duration-500 ${theme.tabWrapper}`}>
          {t.pricing.tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center px-6 py-3 rounded-xl text-sm font-bold transition-all ${
                activeTab === tab.id
                  ? 'bg-amber-500 text-slate-950 shadow-md shadow-amber-500/20'
                  : theme.tabDefault
              }`}
            >
              {tab.id === 'digital' ? <Palette className="w-4 h-4 mr-2" /> : <Sparkles className="w-4 h-4 mr-2" />}
              {tab.label}
            </button>
          ))}
        </div>

        <AnimatePresence mode="wait">
          <div className={`grid grid-cols-1 ${plans.length === 1 ? 'md:grid-cols-1 max-w-sm' : plans.length === 2 ? 'md:grid-cols-2 max-w-3xl' : 'md:grid-cols-3 max-w-5xl'} gap-8 mx-auto`}>
            {plans.map((plan, i) => {
              const planKey = `${activeTab}-${i}`;
              const totalPrice = calculatePlanTotal(plan, planKey);
              const rotation = i % 2 === 0 ? -6 : 4;

              return (
                <motion.div
                  key={planKey}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.3, delay: i * 0.1 }}
                >
                  <Card variant="pricing" hover popular={plan.popular} rotate={plan.popular ? 0 : rotation} className="relative flex flex-col p-8 rounded-xl border-4">
                    <StickyTape rotation={rotation} />

                    {plan.popular && <PopularBadge>{t.pricing.popular}</PopularBadge>}

                    <div className="mb-8 mt-2">
                      <h3 className={`text-2xl font-black mb-2 uppercase tracking-widest transition-colors duration-500 ${theme.heading}`}>{plan.title}</h3>
                      {plan.desc && (
                        <p className={`text-sm mb-4 font-bold border-l-4 border-amber-500 pl-3 transition-colors duration-500 ${theme.subheading}`}>{plan.desc}</p>
                      )}
                      <div className="flex items-baseline gap-1 mt-6">
                        <span className={`text-5xl font-black transition-colors duration-500 ${theme.heading}`}>
                          {formatPrice(totalPrice, currency)}
                        </span>
                        <span className={`font-black text-xl transition-colors duration-500 ${theme.heading}`}>{currency}</span>
                      </div>
                    </div>

                    <div className="flex-1">
                      <p className={`text-sm border-b-4 pb-3 mb-4 font-black uppercase tracking-wider transition-colors duration-500 ${theme.bg.includes('dark') ? 'border-amber-500/30 text-amber-500' : 'border-slate-900 text-slate-700'}`}>
                        {t.pricing.addons}
                      </p>
                      <ul className="space-y-4">
                        {plan.addons.map((addon, idx) => {
                          const isSelected = (selectedAddons[planKey] || []).includes(addon.name);
                          const hasPrice = addon.price_brl !== undefined && addon.price_usd !== undefined;
                          const addonPriceVal = currency === 'BRL' ? addon.price_brl : addon.price_usd;

                          return (
                            <li
                              key={idx}
                              onClick={() => hasPrice && toggleAddon(planKey, addon.name)}
                              className={`flex justify-between items-center text-sm font-bold group cursor-pointer p-1 -m-1 rounded-lg transition-colors ${hasPrice ? 'hover:bg-slate-900/5 dark:hover:bg-white/5' : 'cursor-default'}`}
                            >
                              <div className="flex items-center gap-3">
                                {hasPrice && (
                                  <motion.div
                                    className={`w-5 h-5 rounded border-2 transition-all flex items-center justify-center ${
                                      isSelected
                                        ? 'bg-amber-400 border-slate-900 shadow-[2px_2px_0px_#1e293b]'
                                        : 'bg-white border-slate-300 group-hover:border-slate-900 dark:bg-slate-800 dark:border-slate-700 dark:group-hover:border-amber-400'
                                    }`}
                                    whileTap={{ scale: 0.9 }}
                                  >
                                    {isSelected && <div className="w-2.5 h-2.5 bg-slate-950 rounded-sm" />}
                                  </motion.div>
                                )}
                                <span className={`transition-colors duration-500 ${isSelected ? 'text-amber-600 font-black' : theme.addonLabel}`}>{addon.name}</span>
                                {addon.type === 'per_unit' && (
                                  <span className="text-xs px-2 py-0.5 rounded bg-amber-100 dark:bg-amber-900/30 text-amber-800 dark:text-amber-300 font-medium">
                                    por unidade
                                  </span>
                                )}
                              </div>
                              {hasPrice && (
                                <motion.span
                                  className={`font-black font-mono text-xs border-2 px-2 py-1 transition-colors duration-500 ${
                                    isSelected
                                      ? 'bg-amber-400 border-slate-900 text-slate-900 shadow-[2px_2px_0px_#1e293b]'
                                      : theme.addonPrice
                                  }`}
                                  whileTap={{ scale: 1.05 }}
                                >
                                  {formatPrice(addonPriceVal, currency, true)}
                                </motion.span>
                              )}
                            </li>
                          );
                        })}
                      </ul>
                    </div>

                    <Button
                      onClick={() => handleSelectPlan(plan, planKey, totalPrice)}
                      className={`mt-8 w-full py-3.5 text-center font-black uppercase tracking-widest transition-all border-4 hover:-translate-y-1 active:translate-y-1 ${
                        plan.popular ? theme.pricingSelectPopular : theme.pricingSelectBase
                      }`}
                      size="lg"
                    >
                      {t.pricing.select}
                    </Button>
                  </Card>
                </motion.div>
              );
            })}
          </div>
        </AnimatePresence>
      </div>

      <AnimatePresence>
        {showToast && (
          <motion.div
            initial={{ opacity: 0, y: 50, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 50, scale: 0.9 }}
            className={`fixed bottom-6 right-6 z-[200] max-w-sm w-full p-4 rounded-xl border-2 shadow-[8px_8px_0px_#1e293b] dark:shadow-[8px_8px_0px_#020617] flex items-start gap-4 ${
              isDarkMode ? 'bg-slate-800 border-slate-700 text-slate-200' : 'bg-white border-slate-900 text-slate-800'
            }`}
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
    </motion.section>
  );
}

// const isDarkMode = document.documentElement.classList.contains('dark');