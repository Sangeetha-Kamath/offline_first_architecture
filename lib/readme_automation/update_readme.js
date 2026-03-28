const { execSync } = require("child_process");
const fs = require("fs");

// Get all commit messages
const commits = execSync("git log --pretty=format:%s").toString().split("\n");

// Filter only features
const features = commits
  .filter(msg => msg.startsWith("feat:"))
  .map(msg => msg.replace("feat:", "").trim());

// Remove duplicates
const uniqueFeatures = [...new Set(features)];

const readmePath = "README.md";

// If README doesn't exist, create one
if (!fs.existsSync(readmePath)) {
  fs.writeFileSync(readmePath, "# My Flutter App\n");
}

let content = fs.readFileSync(readmePath, "utf-8");

// New feature section
const featureSection = `
## 🚀 Features
${uniqueFeatures.map(f => `- ${f}`).join("\n")}
`;

// Replace or append
if (content.includes("## 🚀 Features")) {
  content = content.replace(/## 🚀 Features[\s\S]*?(?=\n##|$)/, featureSection);
} else {
  content += "\n" + featureSection;
}

fs.writeFileSync(readmePath, content);

console.log("README updated!");