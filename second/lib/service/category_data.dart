import 'package:second/models/category_model.dart';
import 'package:second/pages/apple_page.dart';
import 'package:second/pages/business_page.dart';
import 'package:second/pages/technology_page.dart';
import 'package:second/pages/tesla_page.dart';
import 'package:second/pages/trending_page.dart';
import 'package:second/pages/wallstreet_page.dart';

List<CategoryModel> getCategories() {
  List<CategoryModel> category = [];
  CategoryModel categoryModel = new CategoryModel();

  // Apple category
  categoryModel.categoryName = "Apple";
  categoryModel.image = "images/Apple.png";
  categoryModel.categoryUrl = ApplePage();
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  // Business category
  categoryModel.categoryName = "Business";
  categoryModel.image = "images/Business.png";
  categoryModel.categoryUrl = BusinessPage();
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  // Technology category
  categoryModel.categoryName = "Technology";
  categoryModel.image = "images/Tech.jpg";
  categoryModel.categoryUrl = TechnologyPage();
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  // Tesla category
  categoryModel.categoryName = "Tesla";
  categoryModel.image = "images/Tesla.jpg";
  categoryModel.categoryUrl = TeslaPage();
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  // Trending category
  categoryModel.categoryName = "Trending";
  categoryModel.image = "images/General.jpg";
  categoryModel.categoryUrl = TrendingPage();
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  // Wall Street category
  categoryModel.categoryName = "Wall Street";
  categoryModel.image = "images/Wall.jpg";
  categoryModel.categoryUrl = WallStreetPage();
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  return category;
}
