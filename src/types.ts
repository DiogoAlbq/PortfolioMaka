import React from 'react';
import { MotionValue } from 'motion/react';

export type Language = 'PT' | 'EN';
export type Currency = 'BRL' | 'USD';
export type PortfolioTab = 'all' | 'art' | 'video' | 'nsfw';
export type PricingTab = 'digital' | 'special';

export interface PlanAddon {
  name: string;
  price_brl: number;
  price_usd: number;
  type?: string;
}

export interface Plan {
  id?: string;
  title: string;
  price_brl: number;
  price_usd: number;
  desc?: string;
  popular?: boolean;
  addons: PlanAddon[];
}

export interface PricingTabs {
  digital: Plan[];
  special: Plan[];
}

export interface Translations {
  EN: TranslationSet;
  PT: TranslationSet;
}

export interface TranslationSet {
  nav: NavTranslations;
  hero: HeroTranslations;
  portfolio: PortfolioTranslations;
  pricing: PricingTranslations;
  tos: ToSTranslations;
  contact: ContactTranslations;
  nsfwModal: NSFWModalTranslations;
  footer: string;
  toast: ToastTranslations;
}

export interface NavTranslations {
  home: string;
  portfolio: string;
  services: string;
  terms: string;
  contact: string;
  order: string;
}

export interface HeroTranslations {
  status: string;
  title1: string;
  title2: string;
  desc: string;
  btn1: string;
  btn2: string;
}

export interface PortfolioTranslations {
  title: string;
  desc: string;
  typeImage: string;
  typeVideo: string;
  tabs: Array<{ id: PortfolioTab; label: string }>;
}

export interface PricingTranslations {
  title: string;
  desc: string;
  tabs: Array<{ id: PricingTab; label: string }>;
  popular: string;
  addons: string;
  select: string;
}

export interface ToSTranslations {
  title: string;
  subtitle: string;
  do: string;
  dont: string;
  doList: string[];
  dontList: string[];
  howToOrder: {
    title: string;
    methodsLabel: string;
    methods: string;
    infoLabel: string;
    info: string;
  };
  terms: {
    title: string;
    list: string[];
  };
}

export interface ContactTranslations {
  title: string;
  subtitle: string;
  name: string;
  email: string;
  projectType: string;
  details: string;
  projectPlaceholder: string;
  btn: string;
}

export interface NSFWModalTranslations {
  title: string;
  message: string;
  confirm: string;
  cancel: string;
}

export interface ToastTranslations {
  success: string;
  greeting: string;
  plan: string;
  basePrice: string;
  addons: string;
  total: string;
}

export interface PortfolioItem {
  type: 'image' | 'video';
  color: string;
  iconColor: string;
  icon: React.ReactNode;
  double?: boolean;
  vertical?: boolean;
  mediaUrl?: string;
}

export interface ThemeColors {
  bg: string;
  navBg: string;
  mobileNavBg: string;
  navLink: string;
  socialBtn: string;
  secondaryBtn: string;
  sectionBg: string;
  tabWrapper: string;
  tabDefault: string;
  card: string;
  pricingCard: string;
  tapeFill: string;
  pricingSelectBase: string;
  pricingSelectPopular: string;
  addonLabel: string;
  addonPrice: string;
  heading: string;
  subheading: string;
  heroBadge: string;
  overlayEnd: string;
  overlaySide: string;
  tosBoxGood: string;
  tosBoxBad: string;
  tosBoxInfo: string;
  tosTitleGood: string;
  tosTitleBad: string;
  tosTitleInfo: string;
  footerIcon: string;
}

export interface ScrollProgress {
  scrollYProgress: MotionValue<number>;
  progressBarColor: MotionValue<string>;
}