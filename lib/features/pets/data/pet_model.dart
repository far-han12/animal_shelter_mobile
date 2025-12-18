class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String gender;
  final String size;
  final String status;
  final String description;
  final List<String> photos;
  final String? medicalNotes;
  final bool specialNeeds;
  final dynamic ownerContact;
  final DateTime createdAt;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.size,
    required this.status,
    required this.description,
    required this.photos,
    this.medicalNotes,
    this.specialNeeds = false,
    this.ownerContact,
    required this.createdAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      size: json['size'] ?? '',
      status: json['status'] ?? 'AVAILABLE',
      description: json['description'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      medicalNotes: json['medicalNotes'],
      specialNeeds: json['specialNeeds'] ?? false,
      ownerContact: json['ownerContact'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
