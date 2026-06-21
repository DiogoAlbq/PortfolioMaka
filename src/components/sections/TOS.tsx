import React from 'react';
import { motion } from 'motion/react';
import { CheckCircle2, XCircle, MessageSquare, FileText } from 'lucide-react';
import { ThemeColors } from '../../types';

interface TOSProps {
  theme: ThemeColors;
  t: any;
}

export function TOS({ theme, t }: TOSProps) {
  return (
    <motion.section
      id="tos"
      initial={{ opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: '-100px' }}
      transition={{ duration: 0.6 }}
      className={`py-16 px-6 backdrop-blur-xl border-y transition-colors duration-500 ${theme.sectionBg}`}
    >
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-16">
          <h2 className={`text-3xl md:text-5xl font-extrabold mb-4 tracking-tight transition-colors duration-500 ${theme.heading}`}>{t.tos.title}</h2>
          <p className={`font-medium text-lg transition-colors duration-500 ${theme.subheading}`}>{t.tos.subtitle}</p>
        </div>

        <div className="grid md:grid-cols-2 gap-8">
          <div className={`p-8 md:p-10 rounded-2xl transition-all duration-500 hover:-translate-y-2 ${theme.tosBoxGood}`}>
            <div className="flex items-center gap-3 mb-6">
              <div className={`p-2 rounded-xl transition-colors duration-500 ${theme.tosTitleGood}`}>
                <CheckCircle2 className="w-7 h-7" />
              </div>
              <h3 className={`text-2xl font-bold w-full tracking-tight transition-colors duration-500 ${theme.heading}`}>{t.tos.do}</h3>
            </div>
            <ul className={`space-y-4 font-medium transition-colors duration-500 ${theme.subheading}`}>
              {t.tos.doList.map((item, idx) => (
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
              <h3 className={`text-2xl font-bold tracking-tight transition-colors duration-500 ${theme.heading}`}>{t.tos.dont}</h3>
            </div>
            <ul className={`space-y-4 font-medium transition-colors duration-500 ${theme.subheading}`}>
              {t.tos.dontList.map((item, idx) => (
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
              <h3 className={`text-2xl font-bold tracking-tight transition-colors duration-500 ${theme.heading}`}>{t.tos.howToOrder.title}</h3>
            </div>

            <div className="space-y-6">
              <div>
                <h4 className={`font-semibold mb-2 ${theme.heading}`}>{t.tos.howToOrder.methodsLabel}</h4>
                <p className={`font-medium ${theme.subheading}`}>{t.tos.howToOrder.methods}</p>
              </div>
              <div>
                <h4 className={`font-semibold mb-2 ${theme.heading}`}>{t.tos.howToOrder.infoLabel}</h4>
                <p className={`font-medium ${theme.subheading}`}>{t.tos.howToOrder.info}</p>
              </div>
            </div>
          </div>

          <div className={`p-8 md:p-10 rounded-2xl transition-all duration-500 hover:-translate-y-2 ${theme.tosBoxInfo}`}>
            <div className="flex items-center gap-3 mb-6">
              <div className={`p-2 rounded-xl transition-colors duration-500 ${theme.tosTitleInfo}`}>
                <FileText className="w-7 h-7" />
              </div>
              <h3 className={`text-2xl font-bold tracking-tight transition-colors duration-500 ${theme.heading}`}>{t.tos.terms.title}</h3>
            </div>

            <ul className={`space-y-4 font-medium transition-colors duration-500 ${theme.subheading}`}>
              {t.tos.terms.list.map((item, idx) => (
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
  );
}