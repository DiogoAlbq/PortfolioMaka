import { Palette, Video, Image as ImageIcon } from 'lucide-react';
import React from 'react';

export const exchangeRate = 5.75;

export const t = {
    EN: {
        nav: { home: "Home", portfolio: "Portfolio", services: "Services", terms: "Terms", contact: "Contact", order: "Book Now" },
        hero: { status: "Commissions Open", title1: "Artist | Fan Dubber |", title2: "Editor | Pixel Artist", desc: "Simple and goofy cartoons", btn1: "See Services", btn2: "Explore Portfolio" },
        portfolio: { title: "Recent Projects", desc: "A selection of my best digital art and video editing projects.", typeImage: "Illustration", typeVideo: "Video Edit", tabs: [{id: 'all', label: 'All'}, {id: 'video', label: 'Video'}, {id: 'nsfw', label: 'NSFW (18+)'}] },
        pricing: { title: "Investment", desc: "Base values for projects. Final price may vary depending on project complexity. Contact me for custom quotes.", tabs: [{id: 'digital', label: 'Digital Art'}, {id: 'special', label: 'Other Services'}], popular: "Most Popular", addons: "Add-ons", select: "Select" },
        pricingPlans: {
            digital: [
                {
                    title: 'Headshot / Icon',
                    price: '35',
                    addons: [
                        { name: 'Background', price: '+20' },
                        { name: 'Extra Character', price: '+30' },
                        { name: 'Items | Accessories', price: '+15' },
                    ]
                },
                {
                    title: 'Half Body',
                    price: '50',
                    addons: [
                        { name: 'NSFW', price: '+25' },
                        { name: 'Background', price: '+20' },
                        { name: 'Extra Character', price: '+25' },
                        { name: 'Items | Accessories', price: '+15' },
                    ]
                },
                {
                    title: 'Full Body',
                    price: '100',
                    popular: true,
                    addons: [
                        { name: 'NSFW', price: '+50' },
                        { name: 'Background', price: '+50' },
                        { name: 'Extra Character', price: '+50' },
                        { name: 'Items | Accessories', price: '+25' },
                    ]
                }
            ],
            special: [
                {
                    title: 'Pixel Art',
                    price: '60',
                    addons: [
                        { name: 'Background', price: '+20' },
                        { name: 'Animated', price: '+100' },
                        { name: 'Extra Character', price: '+30' },
                        { name: 'Items | Accessories', price: '+15' },
                    ]
                },
                {
                    title: 'Pngtuber Remix',
                    price: '80',
                    popular: true,
                    addons: [
                        { name: 'NSFW', price: '+50' },
                        { name: 'Background', price: '+20' },
                        { name: 'Special Features', price: '+150' },
                        { name: 'Extra Character', price: '+50' },
                    ]
                },
                {
                    title: 'Minecraft Skin',
                    price: '75',
                    addons: [
                        { name: 'CPM', price: '+50' },
                        { name: 'MOD mob', price: '+50' },
                    ]
                }
            ]
        },
        tos: { 
            title: "Terms & Conditions", 
            subtitle: "Please read carefully before requesting a commission.", 
            do: "What I do", 
            dont: "What I DO NOT do", 
            doList: ["Original Characters (OCs) of various themes.", "Anime, game, and pop culture fanarts.", "Light armor and sci-fi/cyberpunk designs."], 
            dontList: ["Extreme Gore: Hyper-realistic entrails or mutilations.", "Extreme Fetishes: I reserve the right to refuse requests that make me uncomfortable.", "Comics/Manga: I do not make complete sequential pages.", "NFTs & Crypto: Art shall not be used to fuel blockchains or train AI."],
            howToOrder: {
                title: "How to Order",
                methodsLabel: "Preferred contact method:",
                methods: "Direct message on Discord or Twitter.",
                infoLabel: "What to send in the first message to speed up the process:",
                info: "Character or scenery features | ref sheet | model sheet | scenery details | poses | reference images, etc."
            },
            terms: {
                title: "Terms of Service (T.O.S.), Deadlines & Payment",
                list: [
                    "By commissioning art, the client agrees to the following terms:",
                    "The delivery time can take up to 2 months, depending on project complexity and the queue.",
                    "No 18+ content will be produced featuring real people, clients, or anyone under 18.",
                    "After payment, there are no refunds, regardless of the progress or cancellation of the order.",
                    "The client must provide clear references to avoid mistakes or excessive alterations.",
                    "Minor updates can be made during the process, but major changes after starting the artwork may incur extra costs.",
                    "The artist reserves the right to refuse any request they deem inappropriate or uncomfortable."
                ]
            }
        },
        contact: { title: "Let's Work Together", subtitle: "Fill out the form below with your project details and I will get back to you within 48 hours.", name: "Your Name / Nickname", email: "Your Email", projectType: "Project Type", details: "Project Details", projectPlaceholder: "Describe your idea, provide reference links, and important details...", btn: "Send Request" },
        nsfwModal: { title: "NSFW Content Warning", message: "This content contains Not Safe For Work material. Are you over 18 years old and wish to proceed?", confirm: "Yes, I am 18+", cancel: "Go back" },
        footer: "All rights reserved.",
        toast: { success: "Details copied to clipboard! Paste it in my DMs.", greeting: "Hi Maka! I came from your website! How are you?\nI would like a commission with these details:", plan: "Plan", basePrice: "Base Value", addons: "Add-ons", total: "Estimated Value" }
    },
    PT: {
        nav: { home: "Início", portfolio: "Portfólio", services: "Serviços", terms: "Termos", contact: "Contato", order: "Encomendar Agora" },
        hero: { status: "Comissões Abertas", title1: "Artist | Fan Dubber |", title2: "Editor | Pixel Artist", desc: "Cartoon simples e bobo", btn1: "Ver Serviços e Preços", btn2: "Explorar Portfólio" },
        portfolio: { title: "Trabalhos Recentes", desc: "Uma seleção das minhas melhores artes digitais e vídeos recentes.", typeImage: "Ilustração", typeVideo: "Edição de Vídeo", tabs: [{id: 'all', label: 'Todos'}, {id: 'video', label: 'Vídeos'}, {id: 'nsfw', label: 'NSFW (18+)'}] },
        pricing: { title: "Investimento", desc: "Valores base para projetos. O preço final pode variar dependendo da complexidade do pedido. Entre em contato para orçamentos personalizados.", tabs: [{id: 'digital', label: 'Arte Digital'}, {id: 'special', label: 'Serviços Especiais'}], popular: "Mais Popular", addons: "Adicionais", select: "Selecionar" },
        pricingPlans: {
            digital: [
                {
                    title: 'Cabeça / Ícone',
                    price: '35',
                    addons: [
                        { name: 'Cenário', price: '+20' },
                        { name: 'Personagem Extra', price: '+30' },
                        { name: 'Itens | Acessórios', price: '+15' },
                    ]
                },
                {
                    title: 'Dorso / Metade do Corpo',
                    price: '50',
                    addons: [
                        { name: 'NSFW', price: '+25' },
                        { name: 'Cenário', price: '+20' },
                        { name: 'Personagem Extra', price: '+25' },
                        { name: 'Itens | Acessórios', price: '+15' },
                    ]
                },
                {
                    title: 'Corpo Inteiro',
                    price: '100',
                    popular: true,
                    addons: [
                        { name: 'NSFW', price: '+50' },
                        { name: 'Cenário', price: '+50' },
                        { name: 'Personagem Extra', price: '+50' },
                        { name: 'Itens | Acessórios', price: '+25' },
                    ]
                }
            ],
            special: [
                {
                    title: 'Pixel Arte',
                    price: '60',
                    addons: [
                        { name: 'Cenário', price: '+20' },
                        { name: 'Animado', price: '+100' },
                        { name: 'Personagem Extra', price: '+30' },
                        { name: 'Itens | Acessórios', price: '+15' },
                    ]
                },
                {
                    title: 'Pngtuber Remix',
                    price: '80',
                    popular: true,
                    addons: [
                        { name: 'NSFW', price: '+50' },
                        { name: 'Cenário', price: '+20' },
                        { name: 'Características esp.', price: '+150' },
                        { name: 'Personagem Extra', price: '+50' },
                    ]
                },
                {
                    title: 'Skin minecraft',
                    price: '75',
                    addons: [
                        { name: 'CPM', price: '+50' },
                        { name: 'MOD mob', price: '+50' },
                    ]
                }
            ]
        },
        tos: { 
            title: "Termos & Condições", 
            subtitle: "Por favor, leia atentamente antes de solicitar uma comissão.", 
            do: "O que eu faço", 
            dont: "O que eu NÃO faço", 
            doList: ["Original Characters (OCs) de diversas temáticas.", "Fanarts de animes, jogos e cultura pop.", "Armaduras leves e designs sci-fi / cyberpunk."], 
            dontList: ["Extreme Gore: Tripas ou mutilações hiper-realistas.", "Extreme Fetishes: Reservo-me o direito de recusar pedidos que me causem desconforto.", "Comics / Manga: Não faço páginas sequenciais completas.", "NFTs & Crypto: Nenhuma arte deverá ser usada para alimentar blockchains ou treinar IA."],
            howToOrder: {
                title: "Como Pedir (Fluxo do Cliente)",
                methodsLabel: "Como prefere que o cliente faça o pedido?",
                methods: "Mensagem no Discord e no Twitter.",
                infoLabel: "Para agilizar o processo, o que o cliente deve enviar na primeira mensagem?",
                info: "Características do personagem ou cenário | ref sheet | model sheet | detalhes de cenário | poses | imagem de referência e afins."
            },
            terms: {
                title: "Termos de Serviço (T.O.S.), Prazos e Pagamento",
                list: [
                    "Ao contratar uma arte, o cliente concorda com os seguintes termos:",
                    "O prazo de entrega pode levar até 2 meses, dependendo da complexidade e da fila de pedidos.",
                    "Não serão produzidas artes com conteúdo +18 para/com Pessoas Reais, Clientes, ou menores de 18 anos.",
                    "Após o pagamento, não haverá reembolso, independentemente do andamento ou cancelamento do pedido.",
                    "O cliente deve fornecer referências claras para evitar erros ou alterações excessivas.",
                    "Pequenas atualizações podem ser feitas durante o processo, mas mudanças grandes após o início da arte podem gerar custos extras.",
                    "O artista mantém o direito de recusar qualquer pedido que considere inadequado ou desconfortável."
                ]
            }
        },
        contact: { title: "Vamos Trabalhar Juntos", subtitle: "Preencha o formulário abaixo com os detalhes do seu projeto e retornarei em até 48 horas.", name: "Seu Nome / Nickname", email: "Seu Email", projectType: "Tipo de Projeto", details: "Detalhes do Projeto", projectPlaceholder: "Descreva sua ideia, forneça links de referência e detalhes importantes...", btn: "Enviar Solicitação" },
        nsfwModal: { title: "Aviso de Conteúdo NSFW", message: "Este conteúdo possui material Not Safe For Work (explicíto). Você tem mais de 18 anos e deseja prosseguir?", confirm: "Sim, tenho +18", cancel: "Voltar" },
        footer: "Todos os direitos reservados.",
        toast: { success: "Detalhes copiados!\nCole a mensagem na DM do artista.", greeting: "Olá, Maka! Vim do seu site! Tudo bem? Espero que sim!\nGostaria de uma comissão com esses detalhes:", plan: "Plano", basePrice: "Valor Base", addons: "Adicionais", total: "Valor Estimado" }
    }
};

export interface PortfolioItem {
  type: string;
  color: string;
  iconColor: string;
  icon: React.JSX.Element;
  double?: boolean;
  vertical?: boolean;
  mediaUrl?: string;
}

export const artItems: PortfolioItem[] = [
  
  ];

export const videoItems: PortfolioItem[] = [
  
  { type: 'video', color: 'from-orange-200 to-yellow-200', iconColor: 'text-orange-600', icon: <Video className="w-10 h-10" />, double: true },

  ];

export const nsfwItems: PortfolioItem[] = [
  
  ];

export const heroBgImages = [
  "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80",
  "https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=1200&q=80",
  "https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=1200&q=80",
  "https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?auto=format&fit=crop&w=1200&q=80"
];
