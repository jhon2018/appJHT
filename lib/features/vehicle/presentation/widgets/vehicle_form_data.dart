// lib/features/vehicle/presentation/widgets/vehicle_form_data.dart
// Diccionarios de marcas, modelos, colores y tipos para el formulario de vehículos
import 'package:flutter/material.dart';

// ─── Marcas de vehículos relevantes en Perú ─────────────────────────────────
const kMarcasVehiculo = [
  'Toyota', 'Hyundai', 'Kia', 'Chevrolet', 'Nissan',
  'Mitsubishi', 'Suzuki', 'Ford', 'Volkswagen', 'Honda',
  'Mazda', 'Subaru', 'Renault', 'Peugeot', 'Fiat',
  'Jeep', 'JAC', 'Changan', 'Great Wall', 'Haval',
  'MG', 'BYD', 'Chery', 'Geely', 'Foton',
  'Hino', 'Isuzu', 'Mercedes-Benz', 'Volvo', 'Scania',
  'MAN', 'DAF', 'Freightliner', 'Kenworth', 'International',
  'Dodge', 'RAM', 'Citroën', 'DFSK', 'Shacman',
];

// ─── Modelos por marca (~10 c/u) ────────────────────────────────────────────
const kModelosPorMarca = <String, List<String>>{
  'Toyota': ['Hilux', 'Land Cruiser', 'RAV4', 'Corolla', 'Yaris', 'Fortuner', 'Prado', 'Hiace', 'Dyna', 'Coaster'],
  'Hyundai': ['Tucson', 'Santa Fe', 'Accent', 'Creta', 'Venue', 'Elantra', 'HD78', 'HD65', 'County', 'Mighty'],
  'Kia': ['Sportage', 'Seltos', 'Sorento', 'Picanto', 'Rio', 'Cerato', 'Carnival', 'K2700', 'Bongo', 'Stonic'],
  'Chevrolet': ['Sail', 'Tracker', 'Onix', 'Groove', 'Captiva', 'N300', 'N400', 'NHR', 'NKR', 'FVR'],
  'Nissan': ['Frontier', 'Navara', 'X-Trail', 'Qashqai', 'Sentra', 'Versa', 'NP300', 'Urvan', 'Atlas', 'Cabstar'],
  'Mitsubishi': ['L200', 'Outlander', 'ASX', 'Eclipse Cross', 'Montero', 'Canter', 'Fighter', 'Rosa', 'Fuso', 'Super Great'],
  'Suzuki': ['Swift', 'Vitara', 'Jimny', 'S-Cross', 'Ertiga', 'Baleno', 'Ciaz', 'Carry', 'APV', 'XL7'],
  'Ford': ['Ranger', 'Explorer', 'Escape', 'Territory', 'Bronco', 'F-150', 'Transit', 'Cargo', 'Maverick', 'Ecosport'],
  'Volkswagen': ['Amarok', 'T-Cross', 'Tiguan', 'Taos', 'Virtus', 'Polo', 'Gol', 'Saveiro', 'Crafter', 'Delivery'],
  'Honda': ['CR-V', 'HR-V', 'Civic', 'City', 'WR-V', 'Accord', 'Pilot', 'Fit', 'BR-V', 'Passport'],
  'Mazda': ['CX-5', 'CX-30', 'CX-3', 'Mazda3', 'Mazda2', 'Mazda6', 'CX-50', 'BT-50', 'CX-9', 'MX-5'],
  'Subaru': ['Forester', 'Outback', 'XV', 'Impreza', 'WRX', 'Legacy', 'Crosstrek', 'BRZ', 'Ascent', 'Solterra'],
  'Renault': ['Duster', 'Kwid', 'Logan', 'Stepway', 'Koleos', 'Captur', 'Kangoo', 'Master', 'Alaskan', 'Sandero'],
  'Peugeot': ['2008', '3008', '5008', '208', '301', '308', 'Partner', 'Boxer', 'Expert', 'Rifter'],
  'Fiat': ['Cronos', 'Pulse', 'Strada', 'Fiorino', 'Ducato', 'Mobi', 'Argo', 'Toro', 'Doblo', 'Uno'],
  'Jeep': ['Compass', 'Renegade', 'Cherokee', 'Grand Cherokee', 'Wrangler', 'Gladiator', 'Commander', 'Wagoneer', 'Avenger', 'Meridian'],
  'JAC': ['T6', 'T8', 'S2', 'S3', 'S4', 'S7', 'X200', 'X350', 'Sunray', 'N-Series'],
  'Changan': ['CS35', 'CS55', 'CS75', 'Alsvin', 'Hunter', 'Star', 'Eado', 'UNI-T', 'UNI-K', 'CX70'],
  'Great Wall': ['Wingle 5', 'Wingle 7', 'Poer', 'H3', 'H5', 'H6', 'Cannon', 'King Kong', 'Steed', 'Safe'],
  'Haval': ['H6', 'Jolion', 'Dargo', 'H2', 'H9', 'F7', 'Big Dog', 'M6', 'H4', 'H7'],
  'MG': ['ZS', 'HS', 'RX5', 'MG5', 'MG3', 'GT', 'Marvel R', 'One', 'Cyberster', 'Extender'],
  'BYD': ['Dolphin', 'Seal', 'Atto 3', 'Han', 'Tang', 'Song', 'Yuan Plus', 'Shark', 'T3', 'T5'],
  'Chery': ['Tiggo 2', 'Tiggo 4', 'Tiggo 7', 'Tiggo 8', 'Arrizo 5', 'Arrizo 6', 'QQ', 'Omoda 5', 'Jaecoo 7', 'Fulwin'],
  'Geely': ['Coolray', 'Azkarra', 'Emgrand', 'Monjaro', 'Okavango', 'Starray', 'Tugella', 'Atlas', 'GX3', 'Boyue'],
  'Foton': ['Tunland', 'Aumark', 'Auman', 'Ollin', 'Toano', 'Gratour', 'View', 'EST', 'BJ', 'Forland'],
  'Hino': ['300', '500', '700', 'Dutro', 'Ranger', 'Profia', 'GH', 'FL', 'FM', 'SG'],
  'Isuzu': ['D-Max', 'MU-X', 'NHR', 'NKR', 'NPR', 'NQR', 'FRR', 'FVR', 'FTR', 'GXR'],
  'Mercedes-Benz': ['Sprinter', 'Actros', 'Atego', 'Accelo', 'Axor', 'Vito', 'Clase V', 'GLC', 'Arocs', 'Econic'],
  'Volvo': ['FH', 'FM', 'FMX', 'FL', 'FE', 'VNL', 'VNR', 'XC60', 'XC90', 'S60'],
  'Scania': ['R-Series', 'S-Series', 'G-Series', 'P-Series', 'L-Series', 'XT', 'Citywide', 'Interlink', 'Touring', 'K-Series'],
  'MAN': ['TGX', 'TGS', 'TGM', 'TGL', 'Lion\'s City', 'Lion\'s Coach', 'CLA', 'eTGM', 'eTGS', 'eTruck'],
  'DAF': ['XF', 'XG', 'XG+', 'CF', 'LF', 'XD', 'XB', 'XFC', 'FAR', 'FAN'],
  'Freightliner': ['Cascadia', 'M2 106', 'M2 112', '114SD', '108SD', 'Columbia', 'Coronado', 'Argosy', 'Business Class', 'EconicSD'],
  'Kenworth': ['T680', 'T880', 'T800', 'W900', 'C500', 'T440', 'T370', 'K270', 'K370', 'W990'],
  'International': ['LT', 'RH', 'HV', 'HX', 'MV', 'CV', 'Durastar', 'ProStar', 'LoneStar', 'WorkStar'],
  'Dodge': ['RAM 1500', 'RAM 2500', 'RAM 3500', 'RAM 4500', 'Durango', 'Charger', 'Challenger', 'Journey', 'Nitro', 'Dakota'],
  'RAM': ['1500', '2500', '3500', '4500', '5500', 'ProMaster', 'ProMaster City', '700', 'TRX', 'Power Wagon'],
  'Citroën': ['C3', 'C4 Cactus', 'C5 Aircross', 'Berlingo', 'Jumper', 'Jumpy', 'C-Elysée', 'SpaceTourer', 'Ami', 'C4 X'],
  'DFSK': ['Glory 580', 'Glory 560', 'Glory 500', 'C35', 'C37', 'K01', 'K05', 'K07', 'Super Cab', 'Mini Van'],
  'Shacman': ['X3000', 'H3000', 'F3000', 'X5000', 'L3000', 'M3000', 'F2000', 'X6000', 'SX2190', 'Delong'],
};

// ─── Colores de vehículos ────────────────────────────────────────────────────
class VehicleColor {
  final String name;
  final Color color;
  const VehicleColor(this.name, this.color);
}

const kColoresVehiculo = [
  VehicleColor('Blanco',       Color(0xFFFFFFF0)),
  VehicleColor('Negro',        Color(0xFF1A1A1A)),
  VehicleColor('Plata',        Color(0xFFC0C0C0)),
  VehicleColor('Gris',         Color(0xFF808080)),
  VehicleColor('Gris Oscuro',  Color(0xFF505050)),
  VehicleColor('Rojo',         Color(0xFFCC0000)),
  VehicleColor('Azul',         Color(0xFF1565C0)),
  VehicleColor('Azul Oscuro',  Color(0xFF0D47A1)),
  VehicleColor('Verde',        Color(0xFF2E7D32)),
  VehicleColor('Amarillo',     Color(0xFFFFD600)),
  VehicleColor('Naranja',      Color(0xFFE65100)),
  VehicleColor('Marrón',       Color(0xFF5D4037)),
  VehicleColor('Beige',        Color(0xFFD7CCC8)),
  VehicleColor('Dorado',       Color(0xFFB8860B)),
  VehicleColor('Celeste',      Color(0xFF4FC3F7)),
  VehicleColor('Vino',         Color(0xFF6A1B2A)),
];

// ─── Tipos de vehículo ───────────────────────────────────────────────────────
const kTiposVehiculo = [
  'Camión', 'Camioneta', 'Bus', 'Minibús', 'Furgoneta',
  'Sedán', 'SUV', 'Pick-up', 'Tráiler', 'Cisterna',
  'Volquete', 'Plataforma', 'Remolcador', 'Semiremolque',
  'Cama Baja', 'Frigorífico', 'Grúa', 'Ambulancia',
];
