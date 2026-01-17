# 🤖 Tutorial 02: Machine Learning Integration

> **Advanced Tutorial Series - NIP v3.0.0**  
> Learn how to integrate machine learning models into your Noodle tools

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Setting Up ML Dependencies](#setting-up-ml-dependencies)
3. [TensorFlow.js Integration](#tensorflowjs-integration)
4. [ONNX Model Integration](#onnx-model-integration)
5. [Feature Engineering Pipelines](#feature-engineering-pipelines)
6. [Building ML-Powered Tools](#building-ml-powered-tools)
7. [Model Versioning & Deployment](#model-versioning--deployment)
8. [A/B Testing ML Models](#ab-testing-ml-models)
9. [Performance Monitoring](#performance-monitoring)
10. [Production Best Practices](#production-best-practices)
11. [Practical Exercises](#practical-exercises)
12. [Conclusion](#conclusion)

---

## Introduction

Machine Learning integration enables NIP tools to make intelligent predictions, classifications, and recommendations. This tutorial covers:

- **TensorFlow.js** for browser-based ML inference
- **ONNX Runtime** for cross-platform model deployment
- **Feature engineering** for data preprocessing
- **Model versioning** for production deployment
- **A/B testing** for model comparison
- **Performance monitoring** for optimization

**Prerequisites:**
- Complete Tutorial 01: Building Your First Tool
- Basic understanding of machine learning concepts
- Node.js 18+ and npm installed
- NIP v3.0.0 CLI installed

---

## Setting Up ML Dependencies

### Installation

```bash
# Create a new ML-powered tool
nip create ml-sentiment-analyzer

cd ml-sentiment-analyzer

# Install ML dependencies
npm install @tensorflow/tfjs @tensorflow/tfjs-node
npm install onnxruntime-node
npm install natural  # For NLP preprocessing
```

### Package.json Configuration

```json
{
  "name": "ml-sentiment-analyzer",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "@noodle-ip": "^3.0.0",
    "@tensorflow/tfjs": "^4.17.0",
    "@tensorflow/tfjs-node": "^4.17.0",
    "onnxruntime-node": "^1.17.0",
    "natural": "^6.12.0"
  }
}
```

---

## TensorFlow.js Integration

### Basic Model Loading

```typescript
// src/ml/tensorflow-loader.ts
import * as tf from '@tensorflow/tfjs-node';

export class TensorFlowModel {
  private model: tf.GraphModel | null = null;

  async loadModel(modelPath: string): Promise<void> {
    try {
      this.model = await tf.loadGraphModel(`file://${modelPath}`);
      console.log('Model loaded successfully');
      console.log('Inputs:', this.model.inputNodes);
      console.log('Outputs:', this.model.outputNodes);
    } catch (error) {
      throw new Error(`Failed to load model: ${error}`);
    }
  }

  async predict(inputData: number[]): Promise<number[]> {
    if (!this.model) {
      throw new Error('Model not loaded');
    }

    // Prepare input tensor
    const input = tf.tensor2d([inputData]);
    
    // Run inference
    const output = await this.model.predict(input) as tf.Tensor;
    
    // Get results
    const results = await output.array();
    
    // Clean up tensors
    input.dispose();
    output.dispose();

    return results[0] as number[];
  }

  dispose(): void {
    if (this.model) {
      this.model.dispose();
    }
  }
}
```

### Sentiment Analysis Example

```typescript
// src/tools/sentiment-tool.ts
import { Tool } from '@noodle-ip';
import { TensorFlowModel } from '../ml/tensorflow-loader.ts';

@Tool({
  name: 'sentiment_analyzer',
  description: 'Analyzes sentiment of text using ML',
  version: '1.0.0',
  parameters: {
    text: {
      type: 'string',
      description: 'Text to analyze',
      required: true
    }
  }
})
export class SentimentAnalyzerTool {
  private model: TensorFlowModel;

  constructor() {
    this.model = new TensorFlowModel();
  }

  async initialize(): Promise<void> {
    await this.model.loadModel('./models/sentiment/model.json');
  }

  async execute(params: { text: string }): Promise<{
    sentiment: 'positive' | 'negative' | 'neutral';
    confidence: number;
    scores: Record<string, number>;
  }> {
    const { text } = params;

    // Preprocess text
    const features = this.extractFeatures(text);

    // Run inference
    const scores = await this.model.predict(features);

    // Get prediction
    const labels = ['negative', 'neutral', 'positive'];
    const maxIndex = scores.indexOf(Math.max(...scores));
    const sentiment = labels[maxIndex];
    const confidence = scores[maxIndex];

    return {
      sentiment,
      confidence,
      scores: {
        negative: scores[0],
        neutral: scores[1],
        positive: scores[2]
      }
    };
  }

  private extractFeatures(text: string): number[] {
    // Simple feature extraction
    // In production, use more sophisticated NLP
    const words = text.toLowerCase().split(/\s+/);
    const wordCount = words.length;
    const avgWordLength = words.reduce((sum, w) => sum + w.length, 0) / wordCount;
    
    // Add more features as needed
    return [wordCount, avgWordLength];
  }

  async cleanup(): Promise<void> {
    this.model.dispose();
  }
}
```

---

## ONNX Model Integration

### ONNX Model Loader

```typescript
// src/ml/onnx-loader.ts
import { InferenceSession, Tensor } from 'onnxruntime-node';

export class ONNXModel {
  private session: InferenceSession | null = null;
  private inputNames: string[] = [];
  private outputNames: string[] = [];

  async loadModel(modelPath: string): Promise<void> {
    try {
      this.session = await InferenceSession.create(modelPath);
      this.inputNames = this.session.inputNames;
      this.outputNames = this.session.outputNames;
      
      console.log('ONNX Model loaded successfully');
      console.log('Inputs:', this.inputNames);
      console.log('Outputs:', this.outputNames);
    } catch (error) {
      throw new Error(`Failed to load ONNX model: ${error}`);
    }
  }

  async predict(inputs: Record<string, number[][]>): Promise<Record<string, number[][]>> {
    if (!this.session) {
      throw new Error('Model not loaded');
    }

    // Prepare input tensors
    const inputTensors: Record<string, Tensor> = {};
    for (const [name, data] of Object.entries(inputs)) {
      inputTensors[name] = new Tensor('float32', data);
    }

    // Run inference
    const outputMap = await this.session.run(inputTensors);

    // Extract results
    const outputs: Record<string, number[][]> = {};
    for (const [name, tensor] of Object.entries(outputMap)) {
      outputs[name] = tensor.data as number[][];
    }

    return outputs;
  }

  dispose(): void {
    if (this.session) {
      this.session.release();
    }
  }
}
```

### Image Classification Tool

```typescript
// src/tools/image-classifier.ts
import { Tool } from '@noodle-ip';
import { ONNXModel } from '../ml/onnx-loader.ts';
import fs from 'fs/promises';

@Tool({
  name: 'image_classifier',
  description: 'Classifies images using pre-trained models',
  version: '1.0.0',
  parameters: {
    imagePath: {
      type: 'string',
      description: 'Path to image file',
      required: true
    },
    model: {
      type: 'string',
      description: 'Model to use (resnet50, mobilenet, etc.)',
      default: 'resnet50'
    }
  }
})
export class ImageClassifierTool {
  private models: Map<string, ONNXModel> = new Map();
  private labels: string[] = [];

  async initialize(): Promise<void> {
    // Load labels
    const labelsPath = './models/imagenet/labels.json';
    this.labels = JSON.parse(await fs.readFile(labelsPath, 'utf-8'));

    // Initialize models
    const resnetModel = new ONNXModel();
    await resnetModel.loadModel('./models/resnet50.onnx');
    this.models.set('resnet50', resnetModel);

    // Add more models as needed
  }

  async execute(params: {
    imagePath: string;
    model: string;
  }): Promise<{
    predictions: Array<{ label: string; confidence: number }>;
    topPrediction: string;
  }> {
    const { imagePath, model } = params;
    const onnxModel = this.models.get(model);

    if (!onnxModel) {
      throw new Error(`Model ${model} not found`);
    }

    // Preprocess image
    const imageData = await this.preprocessImage(imagePath);

    // Run inference
    const outputs = await onnxModel.predict({
      input: imageData
    });

    // Process results
    const probabilities = outputs.output[0];
    const predictions = this.getTopKPredictions(probabilities, 5);

    return {
      predictions,
      topPrediction: predictions[0].label
    };
  }

  private async preprocessImage(imagePath: string): Promise<number[][]> {
    // Load and preprocess image
    // This is a simplified example
    // Use sharp or jimp for actual image processing
    
    // Return dummy data for example
    return [[1, 2, 3]]; // Replace with actual preprocessing
  }

  private getTopKPredictions(
    probabilities: number[],
    k: number
  ): Array<{ label: string; confidence: number }> {
    const indexed = probabilities.map((prob, idx) => ({
      label: this.labels[idx] || `Class ${idx}`,
      confidence: prob
    }));

    return indexed
      .sort((a, b) => b.confidence - a.confidence)
      .slice(0, k);
  }

  async cleanup(): Promise<void> {
    for (const model of this.models.values()) {
      model.dispose();
    }
  }
}
```

---

## Feature Engineering Pipelines

### Pipeline Architecture

```typescript
// src/ml/pipeline.ts
export interface FeatureExtractor {
  extract(data: any): number[];
}

export interface FeatureNormalizer {
  normalize(features: number[]): number[];
}

export class ML Pipeline {
  private extractors: FeatureExtractor[] = [];
  private normalizer?: FeatureNormalizer;

  addExtractor(extractor: FeatureExtractor): void {
    this.extractors.push(extractor);
  }

  setNormalizer(normalizer: FeatureNormalizer): void {
    this.normalizer = normalizer;
  }

  process(data: any): number[] {
    let features: number[] = [];

    // Extract features
    for (const extractor of this.extractors) {
      const extracted = extractor.extract(data);
      features = features.concat(extracted);
    }

    // Normalize features
    if (this.normalizer) {
      features = this.normalizer.normalize(features);
    }

    return features;
  }
}
```

### Text Feature Extractors

```typescript
// src/ml/features/text-extractors.ts
import { WordTokenizer, SentimentAnalyzer, PorterStemmer } from 'natural';

export class BagOfWordsExtractor implements FeatureExtractor {
  private tokenizer: WordTokenizer;
  private vocabulary: Set<string>;

  constructor(vocabulary: string[]) {
    this.tokenizer = new WordTokenizer();
    this.vocabulary = new Set(vocabulary.map(w => w.toLowerCase()));
  }

  extract(text: string): number[] {
    const tokens = this.tokenizer.tokenize(text.toLowerCase());
    const vector = Array.from(this.vocabulary).map(word => 
      tokens.includes(word) ? 1 : 0
    );
    return vector;
  }
}

export class TFIDFExtractor implements FeatureExtractor {
  private idfScores: Map<string, number>;
  private tokenizer: WordTokenizer;

  constructor(idfScores: Record<string, number>) {
    this.idfScores = new Map(Object.entries(idfScores));
    this.tokenizer = new WordTokenizer();
  }

  extract(text: string): number[] {
    const tokens = this.tokenizer.tokenize(text.toLowerCase());
    const termFreq = this.calculateTermFrequency(tokens);
    
    const vector: number[] = [];
    for (const [term, idf] of this.idfScores) {
      const tf = termFreq.get(term) || 0;
      vector.push(tf * idf);
    }
    
    return vector;
  }

  private calculateTermFrequency(tokens: string[]): Map<string, number> {
    const freq = new Map<string, number>();
    for (const token of tokens) {
      freq.set(token, (freq.get(token) || 0) + 1);
    }
    return freq;
  }
}
```

### Normalization Strategies

```typescript
// src/ml/features/normalizers.ts
export class MinMaxNormalizer implements FeatureNormalizer {
  constructor(
    private min: number[] = [],
    private max: number[] = []
  ) {}

  fit(data: number[][]): void {
    const numFeatures = data[0].length;
    this.min = new Array(numFeatures).fill(Infinity);
    this.max = new Array(numFeatures).fill(-Infinity);

    for (const row of data) {
      for (let i = 0; i < numFeatures; i++) {
        this.min[i] = Math.min(this.min[i], row[i]);
        this.max[i] = Math.max(this.max[i], row[i]);
      }
    }
  }

  normalize(features: number[]): number[] {
    return features.map((val, idx) => {
      const range = this.max[idx] - this.min[idx];
      return range === 0 ? 0 : (val - this.min[idx]) / range;
    });
  }
}

export class StandardScaler implements FeatureNormalizer {
  constructor(
    private mean: number[] = [],
    private std: number[] = []
  ) {}

  fit(data: number[][]): void {
    const numFeatures = data[0].length;
    this.mean = new Array(numFeatures).fill(0);
    this.std = new Array(numFeatures).fill(0);

    // Calculate mean
    for (const row of data) {
      for (let i = 0; i < numFeatures; i++) {
        this.mean[i] += row[i];
      }
    }
    for (let i = 0; i < numFeatures; i++) {
      this.mean[i] /= data.length;
    }

    // Calculate standard deviation
    for (const row of data) {
      for (let i = 0; i < numFeatures; i++) {
        this.std[i] += Math.pow(row[i] - this.mean[i], 2);
      }
    }
    for (let i = 0; i < numFeatures; i++) {
      this.std[i] = Math.sqrt(this.std[i] / data.length);
    }
  }

  normalize(features: number[]): number[] {
    return features.map((val, idx) => {
      return this.std[idx] === 0 ? 0 : (val - this.mean[idx]) / this.std[idx];
    });
  }
}
```

---

## Building ML-Powered Tools

### Recommendation System Tool

```typescript
// src/tools/recommender.ts
import { Tool } from '@noodle-ip';
import { MLPipeline } from '../ml/pipeline.ts';
import { TensorFlowModel } from '../ml/tensorflow-loader.ts';

@Tool({
  name: 'product_recommender',
  description: 'Recommends products based on user preferences',
  version: '1.0.0',
  parameters: {
    userId: {
      type: 'string',
      description: 'User ID',
      required: true
    },
    context: {
      type: 'object',
      description: 'Additional context (category, price range, etc.)',
      required: false
    }
  }
})
export class RecommenderTool {
  private model: TensorFlowModel;
  private pipeline: MLPipeline;

  constructor() {
    this.model = new TensorFlowModel();
    this.pipeline = new MLPipeline();
  }

  async initialize(): Promise<void> {
    await this.model.loadModel('./models/recommendation/model.json');
    
    // Setup feature pipeline
    // this.pipeline.addExtractor(new UserBehaviorExtractor());
    // this.pipeline.addExtractor(new ContextExtractor());
    // this.pipeline.setNormalizer(new StandardScaler());
  }

  async execute(params: {
    userId: string;
    context?: Record<string, any>;
  }): Promise<{
    recommendations: Array<{
      productId: string;
      score: number;
      reason: string;
    }>;
  }> {
    const { userId, context = {} } = params;

    // Extract features
    const features = this.pipeline.process({ userId, context });

    // Get predictions
    const scores = await this.model.predict(features);

    // Format recommendations
    const recommendations = scores
      .map((score, idx) => ({
        productId: `product_${idx}`,
        score,
        reason: this.generateReason(score, context)
      }))
      .sort((a, b) => b.score - a.score)
      .slice(0, 10);

    return { recommendations };
  }

  private generateReason(score: number, context: Record<string, any>): string {
    if (score > 0.8) return 'Highly recommended based on your preferences';
    if (score > 0.6) return 'Matches your interests';
    return 'You might also like this';
  }

  async cleanup(): Promise<void> {
    this.model.dispose();
  }
}
```

---

## Model Versioning & Deployment

### Version Configuration

```typescript
// src/ml/model-registry.ts
interface ModelVersion {
  version: string;
  path: string;
  uploadedAt: Date;
  metrics: {
    accuracy?: number;
    precision?: number;
    recall?: number;
    f1Score?: number;
  };
  status: 'staging' | 'production' | 'archived';
}

export class ModelRegistry {
  private versions: Map<string, ModelVersion[]> = new Map();

  registerVersion(modelName: string, version: ModelVersion): void {
    if (!this.versions.has(modelName)) {
      this.versions.set(modelName, []);
    }
    this.versions.get(modelName)!.push(version);
  }

  getVersion(modelName: string, version: string): ModelVersion | undefined {
    return this.versions.get(modelName)?.find(v => v.version === version);
  }

  getProductionVersion(modelName: string): ModelVersion | undefined {
    return this.versions
      .get(modelName)
      ?.find(v => v.status === 'production');
  }

  promoteToProduction(modelName: string, version: string): void {
    // Demote current production version
    const versions = this.versions.get(modelName);
    if (!versions) throw new Error('Model not found');

    versions.forEach(v => {
      if (v.status === 'production') v.status = 'staging';
    });

    // Promote new version
    const targetVersion = versions.find(v => v.version === version);
    if (!targetVersion) throw new Error('Version not found');
    targetVersion.status = 'production';
  }
}
```

### Deployment Strategy

```typescript
// src/ml/deployment.ts
export class ModelDeployment {
  async deployModel(
    modelPath: string,
    targetEnvironment: 'staging' | 'production'
  ): Promise<string> {
    console.log(`Deploying model to ${targetEnvironment}...`);

    // Validate model
    await this.validateModel(modelPath);

    // Run smoke tests
    await this.runSmokeTests(modelPath);

    // Deploy
    const deploymentId = await this.uploadModel(modelPath, targetEnvironment);

    // Health check
    await this.healthCheck(deploymentId);

    return deploymentId;
  }

  private async validateModel(modelPath: string): Promise<void> {
    // Load and validate model structure
    console.log('Validating model structure...');
    // Implementation here
  }

  private async runSmokeTests(modelPath: string): Promise<void> {
    console.log('Running smoke tests...');
    // Implementation here
  }

  private async uploadModel(
    modelPath: string,
    environment: string
  ): Promise<string> {
    // Upload to model storage
    const deploymentId = `deployment_${Date.now()}`;
    console.log(`Model uploaded: ${deploymentId}`);
    return deploymentId;
  }

  private async healthCheck(deploymentId: string): Promise<void> {
    console.log(`Health check for ${deploymentId}...`);
    // Implementation here
  }
}
```

---

## A/B Testing ML Models

### Experiment Configuration

```typescript
// src/ml/ab-testing.ts
export interface ExperimentConfig {
  name: string;
  models: {
    control: string; // Model A
    treatment: string; // Model B
  };
  trafficSplit: number; // 0.0 to 1.0 (e.g., 0.5 for 50/50 split)
  metrics: string[];
  duration: number; // in days
}

export interface ExperimentResult {
  model: string;
  predictions: number;
  correct: number;
  accuracy: number;
  latency: number;
  timestamp: Date;
}

export class ABTestManager {
  private config: ExperimentConfig;
  private results: ExperimentResult[] = [];

  constructor(config: ExperimentConfig) {
    this.config = config;
  }

  shouldUseTreatment(userId: string): boolean {
    // Consistent hashing for user assignment
    const hash = this.hashString(userId);
    return (hash % 100) < (this.config.trafficSplit * 100);
  }

  recordResult(result: ExperimentResult): void {
    this.results.push(result);
  }

  analyze(): {
    winner: string;
    controlStats: any;
    treatmentStats: any;
    significance: number;
  } {
    const controlResults = this.results.filter(r => r.model === this.config.models.control);
    const treatmentResults = this.results.filter(r => r.model === this.config.models.treatment);

    const controlAccuracy = this.calculateAccuracy(controlResults);
    const treatmentAccuracy = this.calculateAccuracy(treatmentResults);

    return {
      winner: treatmentAccuracy > controlAccuracy ? this.config.models.treatment : this.config.models.control,
      controlStats: { accuracy: controlAccuracy, sampleSize: controlResults.length },
      treatmentStats: { accuracy: treatmentAccuracy, sampleSize: treatmentResults.length },
      significance: this.calculateSignificance(controlResults, treatmentResults)
    };
  }

  private hashString(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }

  private calculateAccuracy(results: ExperimentResult[]): number {
    if (results.length === 0) return 0;
    const correct = results.reduce((sum, r) => sum + r.correct, 0);
    const total = results.reduce((sum, r) => sum + r.predictions, 0);
    return correct / total;
  }

  private calculateSignificance(
    control: ExperimentResult[],
    treatment: ExperimentResult[]
  ): number {
    // Simplified significance calculation
    // Use proper statistical tests in production
    return 0.95; // Placeholder
  }
}
```

---

## Performance Monitoring

### Metrics Collection

```typescript
// src/ml/monitoring.ts
export interface PredictionMetrics {
  model: string;
  version: string;
  latency: number;
  memory: number;
  timestamp: Date;
  userId?: string;
}

export class MLMonitor {
  private metrics: PredictionMetrics[] = [];

  recordPrediction(metrics: PredictionMetrics): void {
    this.metrics.push(metrics);
  }

  getMetrics(model: string, timeWindow?: number): PredictionMetrics[] {
    let filtered = this.metrics.filter(m => m.model === model);

    if (timeWindow) {
      const cutoff = new Date(Date.now() - timeWindow);
      filtered = filtered.filter(m => m.timestamp >= cutoff);
    }

    return filtered;
  }

  getStats(model: string, timeWindow?: number): {
    avgLatency: number;
    p95Latency: number;
    p99Latency: number;
    avgMemory: number;
    requestCount: number;
  } {
    const metrics = this.getMetrics(model, timeWindow);

    if (metrics.length === 0) {
      return {
        avgLatency: 0,
        p95Latency: 0,
        p99Latency: 0,
        avgMemory: 0,
        requestCount: 0
      };
    }

    const latencies = metrics.map(m => m.latency).sort((a, b) => a - b);
    const memories = metrics.map(m => m.memory);

    return {
      avgLatency: latencies.reduce((a, b) => a + b, 0) / latencies.length,
      p95Latency: latencies[Math.floor(latencies.length * 0.95)],
      p99Latency: latencies[Math.floor(latencies.length * 0.99)],
      avgMemory: memories.reduce((a, b) => a + b, 0) / memories.length,
      requestCount: metrics.length
    };
  }

  detectAnomalies(model: string, threshold: number = 2): PredictionMetrics[] {
    const metrics = this.getMetrics(model);
    const stats = this.getStats(model);

    const stdDev = this.calculateStdDev(
      metrics.map(m => m.latency),
      stats.avgLatency
    );

    return metrics.filter(m => 
      Math.abs(m.latency - stats.avgLatency) > threshold * stdDev
    );
  }

  private calculateStdDev(values: number[], mean: number): number {
    const squareDiffs = values.map(v => Math.pow(v - mean, 2));
    return Math.sqrt(squareDiffs.reduce((a, b) => a + b, 0) / values.length);
  }
}
```

---

## Production Best Practices

### 1. Model Management

```typescript
// Best practices for model management
export const MODEL_MANAGEMENT_CHECKLIST = {
  versioning: 'Always version your models with semantic versioning',
  documentation: 'Document model training data, hyperparameters, and performance',
  testing: 'Run comprehensive tests before deployment',
  monitoring: 'Monitor model performance and data drift continuously',
  rollback: 'Maintain previous versions for quick rollback',
  storage: 'Use secure, versioned storage for model artifacts'
};
```

### 2. Error Handling

```typescript
// Robust error handling for ML tools
export class MLErrorHandler {
  handlePredictionError(error: Error, fallback: any): any {
    console.error('Prediction error:', error);
    
    // Log error for monitoring
    this.logError(error);

    // Return fallback value
    return fallback;
  }

  private logError(error: Error): void {
    // Send to error tracking service
    console.error('ML Error logged:', {
      message: error.message,
      stack: error.stack,
      timestamp: new Date()
    });
  }
}
```

### 3. Caching Strategy

```typescript
// Cache frequently used predictions
import { LRUCache } from 'lru-cache';

export class PredictionCache {
  private cache = new LRUCache<string, any>({
    max: 500,
    ttl: 1000 * 60 * 5 // 5 minutes
  });

  get(key: string): any | undefined {
    return this.cache.get(key);
  }

  set(key: string, value: any): void {
    this.cache.set(key, value);
  }

  clear(): void {
    this.cache.clear();
  }
}
```

### 4. Resource Management

```typescript
// Proper resource cleanup
export class ResourceManager {
  private resources: Array<{ dispose: () => void }> = [];

  register(resource: { dispose: () => void }): void {
    this.resources.push(resource);
  }

  cleanup(): void {
    for (const resource of this.resources) {
      try {
        resource.dispose();
      } catch (error) {
        console.error('Error disposing resource:', error);
      }
    }
    this.resources = [];
  }
}
```

---

## Practical Exercises

### Exercise 1: Build a Text Classifier

**Task**: Create a tool that classifies text into categories using TensorFlow.js

**Requirements**:
1. Create a text classification tool
2. Implement feature extraction pipeline
3. Train or load a pre-trained model
4. Add versioning support
5. Implement A/B testing between two models

**Starting Point**:
```typescript
// src/tools/text-classifier.ts
import { Tool } from '@noodle-ip';

@Tool({
  name: 'text_classifier',
  description: 'Classifies text into categories',
  version: '1.0.0'
})
export class TextClassifierTool {
  // Your implementation here
}
```

### Exercise 2: Implement Model Monitoring

**Task**: Create a monitoring dashboard for ML model performance

**Requirements**:
1. Track prediction latency
2. Monitor memory usage
3. Alert on anomalies
4. Generate performance reports
5. Visualize metrics over time

### Exercise 3: Build a Recommendation Engine

**Task**: Create a product recommendation system

**Requirements**:
1. User-based collaborative filtering
2. Item-based collaborative filtering
3. Hybrid approach
4. A/B test different algorithms
5. Measure recommendation quality

---

## Conclusion

In this tutorial, you learned how to:

✅ Integrate TensorFlow.js and ONNX models into NIP tools  
✅ Build feature engineering pipelines  
✅ Implement model versioning and deployment  
✅ Set up A/B testing for model comparison  
✅ Monitor ML model performance  
✅ Follow production best practices  

### Next Steps

1. **Tutorial 03**: Real-time Data Processing
2. **Tutorial 04**: Advanced Authentication & Security
3. **Tutorial 05**: Multi-Agent Systems

### Additional Resources

- [TensorFlow.js Documentation](https://www.tensorflow.org/js)
- [ONNX Runtime](https://onnxruntime.ai/)
- [NIP Advanced Examples](https://github.com/noodle-ip/advanced-examples)

---

## 📚 Further Reading

- **Machine Learning Engineering**: "Designing Machine Learning Systems" by Chip Huyen
- **MLOps**: "Introducing MLOps" by Mark Treveil
- **Feature Engineering**: "Feature Engineering for Machine Learning" by Alice Zheng

---

**Version**: 3.0.0  
**Last Updated**: 2025-01-17  
**Authors**: NIP Team  
**License**: MIT
