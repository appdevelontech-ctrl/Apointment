class SearchItem {
  final String name;
  final String image;
  final String type;   // doctor/hospital/category
  final String desc;   // short details

  SearchItem({
    required this.name,
    required this.image,
    required this.type,
    required this.desc,
  });
}

List<SearchItem> searchList = [
  // 💚 Doctors
  SearchItem(
      name: "Cardiologist",
      image: "https://cdn-icons-png.flaticon.com/512/3004/3004458.png",
      type: "Doctor",
      desc: "Heart specialist doctor"
  ),
  SearchItem(
      name: "Physician",
      image: "https://cdn-icons-png.flaticon.com/512/3048/3048127.png",
      type: "Doctor",
      desc: "General health & checkups"
  ),
  SearchItem(
      name: "Dermatologist",
      image: "https://cdn-icons-png.flaticon.com/512/9840/9840665.png",
      type: "Doctor",
      desc: "Skin, hair & nails specialist"
  ),
  SearchItem(
      name: "Pediatrician",
      image: "https://cdn-icons-png.flaticon.com/512/4140/4140047.png",
      type: "Doctor",
      desc: "Child specialist doctor"
  ),

  // 🏥 Hospitals
  SearchItem(
      name: "Fortis Hospital",
      image: "https://cdn-icons-png.flaticon.com/512/2966/2966327.png",
      type: "Hospital",
      desc: "Noida • Sector-63"
  ),
  SearchItem(
      name: "Apollo Hospital",
      image: "https://cdn-icons-png.flaticon.com/512/2966/2966327.png",
      type: "Hospital",
      desc: "Delhi • Multi-speciality"
  ),
  SearchItem(
      name: "Max Super Speciality",
      image: "https://cdn-icons-png.flaticon.com/512/2966/2966327.png",
      type: "Hospital",
      desc: "Saket • Cardiac care"
  ),

  // 🩺 Categories / Specialities
  SearchItem(
      name: "Orthopaedic",
      image: "https://cdn-icons-png.flaticon.com/512/4508/4508315.png",
      type: "Category",
      desc: "Bone & joint specialist"
  ),
  SearchItem(
      name: "Gynecology",
      image: "https://cdn-icons-png.flaticon.com/512/9429/9429620.png",
      type: "Category",
      desc: "Women's health specialist"
  ),
  SearchItem(
      name: "Neurology",
      image: "https://cdn-icons-png.flaticon.com/512/2180/2180655.png",
      type: "Category",
      desc: "Brain & nerves specialist"
  ),
];
