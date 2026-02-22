export interface Property {
  id: string;
  title: string;
  price: number;
  location: string;
  type: "Sale" | "Rent";
  status: "Published" | "Pending" | "Sold";
  bedrooms: number;
  bathrooms: number;
  sqft: number;
  image: string;
  agent: {
    name: string;
    verified: boolean;
    image: string;
  };
  description: string;
}

export const MOCK_PROPERTIES: Property[] = [
  {
    id: "prop_1",
    title: "Luxury Apartment in Victoria Island",
    price: 150000000,
    location: "1024 Adetokunbo Ademola, VI, Lagos",
    type: "Sale",
    status: "Published",
    bedrooms: 3,
    bathrooms: 3,
    sqft: 2200,
    image: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&q=80&w=1000",
    agent: {
      name: "Sarah Okon",
      verified: true,
      image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah",
    },
    description: "A stunning 3-bedroom apartment with ocean view, 24/7 power, and maximum security. Verified title.",
  },
  {
    id: "prop_2",
    title: "Modern Duplex in Lekki Phase 1",
    price: 8500000,
    location: "Block 4, Admiralty Way, Lekki",
    type: "Rent",
    status: "Published",
    bedrooms: 4,
    bathrooms: 5,
    sqft: 3500,
    image: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80&w=1000",
    agent: {
      name: "Emmanuel Kalu",
      verified: true,
      image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Emmanuel",
    },
    description: "Newly built duplex with BQ. Fully serviced estate with gym and pool.",
  },
  {
    id: "prop_3",
    title: "Commercial Space in Ikeja GRA",
    price: 450000000,
    location: "Isaac John Street, Ikeja",
    type: "Sale",
    status: "Published",
    bedrooms: 0,
    bathrooms: 4,
    sqft: 5000,
    image: "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=1000",
    agent: {
      name: "Chinedu Obi",
      verified: false, // Unverified agent example
      image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Chinedu",
    },
    description: "Prime office space in the heart of the mainland. Perfect for corporate headquarters.",
  },
  {
    id: "prop_4",
    title: "Serviced Flat in Maitama",
    price: 12000000,
    location: "Gana Street, Maitama, Abuja",
    type: "Rent",
    status: "Published",
    bedrooms: 2,
    bathrooms: 2,
    sqft: 1500,
    image: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80&w=1000",
    agent: {
      name: "Zainab Ahmed",
      verified: true,
      image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Zainab",
    },
    description: "Exquisite 2-bedroom flat with italian finishing. Diplomatic zone security.",
  },
  {
    id: "prop_5",
    title: "Modern Apartment Owerri",
    price: 35000000,
    location: "Wetheral Road, Owerri, Imo State",
    type: "Sale",
    status: "Published",
    bedrooms: 2,
    bathrooms: 2,
    sqft: 1200,
    image: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Ikenna Uzor", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Ikenna" },
    description: "Cozy 2-bedroom apartment in a secure neighborhood in Owerri."
  },
  {
    id: "prop_6",
    title: "Luxury Villa Port Harcourt",
    price: 120000000,
    location: "GRA Phase 2, Port Harcourt, Rivers State",
    type: "Sale",
    status: "Published",
    bedrooms: 5,
    bathrooms: 6,
    sqft: 4500,
    image: "https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Blessing Amadi", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Blessing" },
    description: "Massive 5-bedroom villa with pool and cinema room."
  },
  {
    id: "prop_7",
    title: "Studio Apartment Abuja",
    price: 1500000,
    location: "Gwarinpa, Abuja",
    type: "Rent",
    status: "Published",
    bedrooms: 1,
    bathrooms: 1,
    sqft: 600,
    image: "https://images.unsplash.com/photo-1536376074432-cd29f0577b6c?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Musa Bello", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Musa" },
    description: "Compact and modern studio apartment in Gwarinpa."
  },
  {
    id: "prop_8",
    title: "Family House Enugu",
    price: 45000000,
    location: "Independence Layout, Enugu State",
    type: "Sale",
    status: "Published",
    bedrooms: 4,
    bathrooms: 4,
    sqft: 2800,
    image: "https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Adaeze Okafor", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Adaeze" },
    description: "Spacious 4-bedroom family home with large garden."
  },
  {
    id: "prop_9",
    title: "Penthouse Lagos",
    price: 250000000,
    location: "Banana Island, Lagos",
    type: "Sale",
    status: "Published",
    bedrooms: 4,
    bathrooms: 5,
    sqft: 3800,
    image: "https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Tunde Ednut", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Tunde" },
    description: "Ultra-luxury penthouse with breathtaking views of the Lagos lagoon."
  },
  {
    id: "prop_10",
    title: "Duplex Port Harcourt",
    price: 75000000,
    location: "Peter Odili Road, Port Harcourt",
    type: "Sale",
    status: "Published",
    bedrooms: 4,
    bathrooms: 4,
    sqft: 3000,
    image: "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Precious Dike", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Precious" },
    description: "Modern duplex in a gated estate."
  },
  {
    id: "prop_11",
    title: "Office Complex Abuja",
    price: 850000000,
    location: "Central Business District, Abuja",
    type: "Sale",
    status: "Published",
    bedrooms: 0,
    bathrooms: 10,
    sqft: 12000,
    image: "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Ibrahim Lawal", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Ibrahim" },
    description: "Full office building in Abuja's CBD."
  },
  {
    id: "prop_12",
    title: "Beach House Lagos",
    price: 180000000,
    location: "Ilase Beach, Lagos",
    type: "Sale",
    status: "Published",
    bedrooms: 3,
    bathrooms: 4,
    sqft: 2500,
    image: "https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Folake Bakare", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Folake" },
    description: "Exclusive beach house getaway."
  },
  {
    id: "prop_13",
    title: "Apartment Owerri North",
    price: 2500000,
    location: "Owerri North, Imo State",
    type: "Rent",
    status: "Published",
    bedrooms: 3,
    bathrooms: 3,
    sqft: 1800,
    image: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Chidi Igwe", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Chidi" },
    description: "Modern 3-bedroom apartment for rent."
  },
  {
    id: "prop_15",
    title: "Luxury Estate Enugu",
    price: 95000000,
    location: "Enugu-Onitsha Expressway, Enugu",
    type: "Sale",
    status: "Published",
    bedrooms: 5,
    bathrooms: 5,
    sqft: 4000,
    image: "https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Adaeze Okafor", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Adaeze" },
    description: "Elegant 5-bedroom estate with modern finishings."
  },
  {
    id: "prop_16",
    title: "Modern Flat Owerri",
    price: 1800000,
    location: "Ikenegbu Layout, Owerri",
    type: "Rent",
    status: "Published",
    bedrooms: 2,
    bathrooms: 2,
    sqft: 1100,
    image: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Chidi Igwe", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Chidi" },
    description: "Fully serviced 2-bedroom flat."
  },
  {
    id: "prop_17",
    title: "Commercial Hub Port Harcourt",
    price: 300000000,
    location: "Trans Amadi, Port Harcourt",
    type: "Sale",
    status: "Published",
    bedrooms: 0,
    bathrooms: 6,
    sqft: 8000,
    image: "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Precious Dike", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Precious" },
    description: "Prime industrial/commercial space."
  },
  {
    id: "prop_18",
    title: "Cozy Studio Abuja",
    price: 22000000,
    location: "Apo Resettlement, Abuja",
    type: "Sale",
    status: "Published",
    bedrooms: 1,
    bathrooms: 1,
    sqft: 550,
    image: "https://images.unsplash.com/photo-1536376074432-cd29f0577b6c?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Musa Bello", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Musa" },
    description: "Modern studio perfect for investment."
  },
  {
    id: "prop_19",
    title: "Family Home Lagos",
    price: 85000000,
    location: "Sangotedo, Ajah, Lagos",
    type: "Sale",
    status: "Published",
    bedrooms: 4,
    bathrooms: 4,
    sqft: 2600,
    image: "https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Folake Bakare", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Folake" },
    description: "Beautiful 4-bedroom terrace."
  },
  {
    id: "prop_20",
    title: "Executive Apartment Port Harcourt",
    price: 4500000,
    location: "Woji, Port Harcourt",
    type: "Rent",
    status: "Published",
    bedrooms: 3,
    bathrooms: 3,
    sqft: 1900,
    image: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Blessing Amadi", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Blessing" },
    description: "High-end 3-bedroom apartment."
  },
  {
    id: "prop_21",
    title: "Land for Development Abuja",
    price: 500000000,
    location: "Guzape, Abuja",
    type: "Sale",
    status: "Published",
    bedrooms: 0,
    bathrooms: 0,
    sqft: 15000,
    image: "https://images.unsplash.com/photo-1500382017468-9049fee74a62?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Fatima Yusuf", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Fatima" },
    description: "Prime land with C of O."
  },
  {
    id: "prop_22",
    title: "Mini Flat Enugu",
    price: 800000,
    location: "New Haven, Enugu",
    type: "Rent",
    status: "Published",
    bedrooms: 1,
    bathrooms: 1,
    sqft: 500,
    image: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Adaeze Okafor", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Adaeze" },
    description: "Clean and secure mini flat."
  },
  {
    id: "prop_23",
    title: "Semi-Detached Duplex Lagos",
    price: 130000000,
    location: "Magodo Phase 2, Lagos",
    type: "Sale",
    status: "Published",
    bedrooms: 4,
    bathrooms: 5,
    sqft: 3200,
    image: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Emmanuel Kalu", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Emmanuel" },
    description: "Luxury duplex in a top estate."
  },
  {
    id: "prop_24",
    title: "Smart Home Abuja",
    price: 180000000,
    location: "Life Camp, Abuja",
    type: "Sale",
    status: "Published",
    bedrooms: 4,
    bathrooms: 4,
    sqft: 3000,
    image: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&q=80&w=1000",
    agent: { name: "Zainab Ahmed", verified: true, image: "https://api.dicebear.com/7.x/avataaars/svg?seed=Zainab" },
    description: "Fully automated smart home."
  },
];

export interface ProService {
  id: string;
  name: string;
  description: string;
  icon: string;
  price: string;
  turnaround: string;
}

export const PROFESSIONAL_SERVICES: ProService[] = [
  {
    id: "serv_1",
    name: "Property Valuation",
    description: "Get a certified valuation report for your property from licensed estate surveyors.",
    icon: "ClipboardCheck",
    price: "₦50,000",
    turnaround: "48 Hours",
  },
  {
    id: "serv_2",
    name: "Land Surveying",
    description: "Professional boundary surveys and topographic mapping by verified surveyors.",
    icon: "Compass",
    price: "₦120,000",
    turnaround: "5-7 Days",
  },
  {
    id: "serv_3",
    name: "Land Info Verification",
    description: "Verify land titles and historical records at the state land registry.",
    icon: "FileSearch",
    price: "₦35,000",
    turnaround: "24 Hours",
  },
  {
    id: "serv_4",
    name: "Snagging Services",
    description: "Detailed inspection of new buildings to identify defects before you move in.",
    icon: "Building2",
    price: "₦45,000",
    turnaround: "48 Hours",
  },
];
