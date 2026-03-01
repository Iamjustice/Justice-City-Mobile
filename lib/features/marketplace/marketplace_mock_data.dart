import 'package:flutter/material.dart';

class MarketplaceAgent {
  const MarketplaceAgent({
    required this.name,
    required this.verified,
    required this.imageUrl,
  });

  final String name;
  final bool verified;
  final String imageUrl;
}

class MarketplaceProperty {
  const MarketplaceProperty({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.type,
    required this.status,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
    required this.imageUrl,
    required this.agent,
    required this.description,
    this.galleryUrls = const [],
  });

  final String id;
  final String title;
  final int price;
  final String location;
  final String type;
  final String status;
  final int bedrooms;
  final int bathrooms;
  final int sqft;
  final String imageUrl;
  final MarketplaceAgent agent;
  final String description;
  final List<String> galleryUrls;
}

class MarketplaceService {
  const MarketplaceService({
    required this.title,
    required this.description,
    required this.icon,
    required this.tint,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color tint;
}

const marketplaceProperties = [
  MarketplaceProperty(
    id: 'prop_1',
    title: 'Luxury Apartment in Victoria Island',
    price: 150000000,
    location: '1024 Adetokunbo Ademola, VI, Lagos',
    type: 'Sale',
    status: 'Published',
    bedrooms: 3,
    bathrooms: 3,
    sqft: 2200,
    imageUrl:
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Sarah Okon',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Sarah',
    ),
    description:
        'A stunning 3-bedroom apartment with ocean view, 24/7 power, and maximum security. Verified title.',
    galleryUrls: [
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&q=80&w=1000',
      'https://images.unsplash.com/photo-1600566752355-35792bedcfea?auto=format&fit=crop&q=80&w=1000',
      'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&q=80&w=1000',
      'https://images.unsplash.com/photo-1600585154526-990dcea4db0d?auto=format&fit=crop&q=80&w=1000',
    ],
  ),
  MarketplaceProperty(
    id: 'prop_2',
    title: 'Modern Duplex in Lekki Phase 1',
    price: 8500000,
    location: 'Block 4, Admiralty Way, Lekki',
    type: 'Rent',
    status: 'Published',
    bedrooms: 4,
    bathrooms: 5,
    sqft: 3500,
    imageUrl:
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Emmanuel Kalu',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Emmanuel',
    ),
    description:
        'Newly built duplex with BQ. Fully serviced estate with gym and pool.',
  ),
  MarketplaceProperty(
    id: 'prop_3',
    title: 'Commercial Space in Ikeja GRA',
    price: 450000000,
    location: 'Isaac John Street, Ikeja',
    type: 'Sale',
    status: 'Published',
    bedrooms: 0,
    bathrooms: 4,
    sqft: 5000,
    imageUrl:
        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Chinedu Obi',
      verified: false,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Chinedu',
    ),
    description:
        'Prime office space in the heart of the mainland. Perfect for corporate headquarters.',
  ),
  MarketplaceProperty(
    id: 'prop_4',
    title: 'Serviced Flat in Maitama',
    price: 12000000,
    location: 'Gana Street, Maitama, Abuja',
    type: 'Rent',
    status: 'Published',
    bedrooms: 2,
    bathrooms: 2,
    sqft: 1500,
    imageUrl:
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Zainab Ahmed',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Zainab',
    ),
    description:
        'Exquisite 2-bedroom flat with italian finishing. Diplomatic zone security.',
  ),
  MarketplaceProperty(
    id: 'prop_5',
    title: 'Modern Apartment Owerri',
    price: 35000000,
    location: 'Wetheral Road, Owerri, Imo State',
    type: 'Sale',
    status: 'Published',
    bedrooms: 2,
    bathrooms: 2,
    sqft: 1200,
    imageUrl:
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Ikenna Uzor',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Ikenna',
    ),
    description:
        'Cozy 2-bedroom apartment in a secure neighborhood in Owerri.',
  ),
  MarketplaceProperty(
    id: 'prop_6',
    title: 'Luxury Villa Port Harcourt',
    price: 120000000,
    location: 'GRA Phase 2, Port Harcourt, Rivers State',
    type: 'Sale',
    status: 'Published',
    bedrooms: 5,
    bathrooms: 6,
    sqft: 4500,
    imageUrl:
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Blessing Amadi',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Blessing',
    ),
    description: 'Massive 5-bedroom villa with pool and cinema room.',
  ),
  MarketplaceProperty(
    id: 'prop_7',
    title: 'Studio Apartment Abuja',
    price: 1500000,
    location: 'Gwarinpa, Abuja',
    type: 'Rent',
    status: 'Published',
    bedrooms: 1,
    bathrooms: 1,
    sqft: 600,
    imageUrl:
        'https://images.unsplash.com/photo-1536376074432-cd29f0577b6c?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Musa Bello',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Musa',
    ),
    description: 'Compact and modern studio apartment in Gwarinpa.',
  ),
  MarketplaceProperty(
    id: 'prop_8',
    title: 'Family House Enugu',
    price: 45000000,
    location: 'Independence Layout, Enugu State',
    type: 'Sale',
    status: 'Published',
    bedrooms: 4,
    bathrooms: 4,
    sqft: 2800,
    imageUrl:
        'https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Adaeze Okafor',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Adaeze',
    ),
    description: 'Spacious 4-bedroom family home with large garden.',
  ),
  MarketplaceProperty(
    id: 'prop_9',
    title: 'Penthouse Lagos',
    price: 250000000,
    location: 'Banana Island, Lagos',
    type: 'Sale',
    status: 'Published',
    bedrooms: 4,
    bathrooms: 5,
    sqft: 3800,
    imageUrl:
        'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Tunde Ednut',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Tunde',
    ),
    description:
        'Ultra-luxury penthouse with breathtaking views of the Lagos lagoon.',
  ),
  MarketplaceProperty(
    id: 'prop_10',
    title: 'Duplex Port Harcourt',
    price: 75000000,
    location: 'Peter Odili Road, Port Harcourt',
    type: 'Sale',
    status: 'Published',
    bedrooms: 4,
    bathrooms: 4,
    sqft: 3000,
    imageUrl:
        'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Precious Dike',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Precious',
    ),
    description: 'Modern duplex in a gated estate.',
  ),
  MarketplaceProperty(
    id: 'prop_11',
    title: 'Office Complex Abuja',
    price: 850000000,
    location: 'Central Business District, Abuja',
    type: 'Sale',
    status: 'Published',
    bedrooms: 0,
    bathrooms: 10,
    sqft: 12000,
    imageUrl:
        'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Ibrahim Lawal',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Ibrahim',
    ),
    description: 'Full office building in Abuja''s CBD.',
  ),
  MarketplaceProperty(
    id: 'prop_12',
    title: 'Beach House Lagos',
    price: 180000000,
    location: 'Ilase Beach, Lagos',
    type: 'Sale',
    status: 'Published',
    bedrooms: 3,
    bathrooms: 4,
    sqft: 2500,
    imageUrl:
        'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Folake Bakare',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Folake',
    ),
    description: 'Exclusive beach house getaway.',
  ),
  MarketplaceProperty(
    id: 'prop_13',
    title: 'Apartment Owerri North',
    price: 2500000,
    location: 'Owerri North, Imo State',
    type: 'Rent',
    status: 'Published',
    bedrooms: 3,
    bathrooms: 3,
    sqft: 1800,
    imageUrl:
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Chidi Igwe',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Chidi',
    ),
    description: 'Modern 3-bedroom apartment for rent.',
  ),
  MarketplaceProperty(
    id: 'prop_15',
    title: 'Luxury Estate Enugu',
    price: 95000000,
    location: 'Enugu-Onitsha Expressway, Enugu',
    type: 'Sale',
    status: 'Published',
    bedrooms: 5,
    bathrooms: 5,
    sqft: 4000,
    imageUrl:
        'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Adaeze Okafor',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Adaeze',
    ),
    description: 'Elegant 5-bedroom estate with modern finishings.',
  ),
  MarketplaceProperty(
    id: 'prop_16',
    title: 'Modern Flat Owerri',
    price: 1800000,
    location: 'Ikenegbu Layout, Owerri',
    type: 'Rent',
    status: 'Published',
    bedrooms: 2,
    bathrooms: 2,
    sqft: 1100,
    imageUrl:
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Chidi Igwe',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Chidi',
    ),
    description: 'Fully serviced 2-bedroom flat.',
  ),
  MarketplaceProperty(
    id: 'prop_17',
    title: 'Commercial Hub Port Harcourt',
    price: 300000000,
    location: 'Trans Amadi, Port Harcourt',
    type: 'Sale',
    status: 'Published',
    bedrooms: 0,
    bathrooms: 6,
    sqft: 8000,
    imageUrl:
        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Precious Dike',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Precious',
    ),
    description: 'Prime industrial and commercial space.',
  ),
  MarketplaceProperty(
    id: 'prop_18',
    title: 'Cozy Studio Abuja',
    price: 22000000,
    location: 'Apo Resettlement, Abuja',
    type: 'Sale',
    status: 'Published',
    bedrooms: 1,
    bathrooms: 1,
    sqft: 550,
    imageUrl:
        'https://images.unsplash.com/photo-1536376074432-cd29f0577b6c?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Musa Bello',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Musa',
    ),
    description: 'Modern studio perfect for investment.',
  ),
  MarketplaceProperty(
    id: 'prop_19',
    title: 'Family Home Lagos',
    price: 85000000,
    location: 'Sangotedo, Ajah, Lagos',
    type: 'Sale',
    status: 'Published',
    bedrooms: 4,
    bathrooms: 4,
    sqft: 2600,
    imageUrl:
        'https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Folake Bakare',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Folake',
    ),
    description: 'Beautiful 4-bedroom terrace.',
  ),
  MarketplaceProperty(
    id: 'prop_20',
    title: 'Executive Apartment Port Harcourt',
    price: 4500000,
    location: 'Woji, Port Harcourt',
    type: 'Rent',
    status: 'Published',
    bedrooms: 3,
    bathrooms: 3,
    sqft: 1900,
    imageUrl:
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Blessing Amadi',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Blessing',
    ),
    description: 'High-end 3-bedroom apartment.',
  ),
  MarketplaceProperty(
    id: 'prop_21',
    title: 'Land for Development Abuja',
    price: 500000000,
    location: 'Guzape, Abuja',
    type: 'Sale',
    status: 'Published',
    bedrooms: 0,
    bathrooms: 0,
    sqft: 15000,
    imageUrl:
        'https://images.unsplash.com/photo-1500382017468-9049fee74a62?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Fatima Yusuf',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Fatima',
    ),
    description: 'Prime land with certificate of occupancy.',
  ),
  MarketplaceProperty(
    id: 'prop_22',
    title: 'Mini Flat Enugu',
    price: 800000,
    location: 'New Haven, Enugu',
    type: 'Rent',
    status: 'Published',
    bedrooms: 1,
    bathrooms: 1,
    sqft: 500,
    imageUrl:
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Adaeze Okafor',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Adaeze',
    ),
    description: 'Clean and secure mini flat.',
  ),
  MarketplaceProperty(
    id: 'prop_23',
    title: 'Semi-Detached Duplex Lagos',
    price: 130000000,
    location: 'Magodo Phase 2, Lagos',
    type: 'Sale',
    status: 'Published',
    bedrooms: 4,
    bathrooms: 5,
    sqft: 3200,
    imageUrl:
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Emmanuel Kalu',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Emmanuel',
    ),
    description: 'Luxury duplex in a top estate.',
  ),
  MarketplaceProperty(
    id: 'prop_24',
    title: 'Smart Home Abuja',
    price: 180000000,
    location: 'Life Camp, Abuja',
    type: 'Sale',
    status: 'Published',
    bedrooms: 4,
    bathrooms: 4,
    sqft: 3000,
    imageUrl:
        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&q=80&w=1000',
    agent: MarketplaceAgent(
      name: 'Zainab Ahmed',
      verified: true,
      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Zainab',
    ),
    description: 'Fully automated smart home.',
  ),
];

const marketplaceServices = [
  MarketplaceService(
    title: 'Land Surveying',
    description:
        'Accurate boundary mapping and topographical surveys by licensed professionals.',
    icon: Icons.explore_outlined,
    tint: Color(0xFF2563EB),
  ),
  MarketplaceService(
    title: 'Property Valuation',
    description:
        'Professional appraisal services to determine the true market value of any asset.',
    icon: Icons.assignment_turned_in_outlined,
    tint: Color(0xFF16A34A),
  ),
  MarketplaceService(
    title: 'Land Verification',
    description:
        'Complete document review and physical site inspection for absolute peace of mind.',
    icon: Icons.shield_outlined,
    tint: Color(0xFF9333EA),
  ),
];

MarketplaceProperty? marketplacePropertyById(String id) {
  for (final property in marketplaceProperties) {
    if (property.id == id) return property;
  }
  return null;
}
