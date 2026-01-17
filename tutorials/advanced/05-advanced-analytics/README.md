# 📊 Advanced Analytics in NIP v3.0.0

## Table of Contents
- [Introduction](#introduction)
- [Custom Metrics Collection](#custom-metrics-collection)
- [Real-Time Dashboards](#real-time-dashboards)
- [Data Visualization](#data-visualization)
- [Event Tracking](#event-tracking)
- [Funnel Analysis](#funnel-analysis)
- [Cohort Analysis](#cohort-analysis)
- [Predictive Analytics](#predictive-analytics)
- [Alerting and Notifications](#alerting-and-notifications)
- [Integration with Grafana/Prometheus](#integration-with-grafanaprometheus)
- [Practical Exercises](#practical-exercises)
- [Best Practices](#best-practices)

---

## Introduction

Advanced analytics in NIP v3.0.0 enables deep insights into your application's performance, user behavior, and business metrics. This tutorial covers sophisticated analytics techniques to help you make data-driven decisions.

### Learning Objectives
- Implement custom metrics collection
- Build real-time dashboards
- Visualize complex data patterns
- Track user events and behaviors
- Analyze conversion funnels
- Perform cohort analysis
- Apply predictive analytics
- Set up intelligent alerting

### Prerequisites
- Completed Tutorial 01 (Basic Metrics)
- NIP v3.0.0 installed
- Basic understanding of statistics
- Familiarity with data visualization concepts

---

## Custom Metrics Collection

Custom metrics allow you to track domain-specific data points that matter to your business.

### Business Metrics

```typescript
import { MetricsRegistry } from '@nip/core/metrics';

class BusinessMetrics {
  private registry: MetricsRegistry;

  constructor(registry: MetricsRegistry) {
    this.registry = registry;
  }

  // Track revenue-related metrics
  trackRevenue(amount: number, source: string) {
    this.registry.counter('revenue_total', {
      labels: { source },
      value: amount
    });

    this.registry.histogram('revenue_distribution', {
      value: amount,
      labels: { source },
      buckets: [10, 50, 100, 500, 1000, 5000, 10000]
    });
  }

  // Track user engagement
  trackUserEngagement(userId: string, action: string, duration: number) {
    this.registry.counter('user_actions_total', {
      labels: {
        user: userId,
        action: action
      }
    });

    this.registry.gauge('user_session_duration', {
      value: duration,
      labels: { user: userId }
    });
  }

  // Track conversion rates
  trackConversion(step: string, status: 'success' | 'failed', value: number = 1) {
    this.registry.counter('conversion_steps_total', {
      labels: {
        step: step,
        status: status
      },
      value: value
    });
  }
}

// Usage
const metrics = new BusinessMetrics(metricsRegistry);
metrics.trackRevenue(99.99, 'web');
metrics.trackUserEngagement('user_123', 'checkout', 450);
metrics.trackConversion('payment_initiated', 'success');
```

### Custom Aggregations

```typescript
class AggregatedMetrics {
  private registry: MetricsRegistry;

  constructor(registry: MetricsRegistry) {
    this.registry = registry;
  }

  // Calculate average order value
  calculateAverageOrderValue(orders: number[]): void {
    const avg = orders.reduce((a, b) => a + b, 0) / orders.length;
    
    this.registry.gauge('average_order_value', {
      value: avg,
      labels: { period: 'daily' }
    });
  }

  // Track customer lifetime value
  calculateCustomerLifetimeValue(userId: string, purchases: number[]): void {
    const clv = purchases.reduce((a, b) => a + b, 0);
    
    this.registry.gauge('customer_lifetime_value', {
      value: clv,
      labels: { user: userId }
    });
  }

  // Calculate retention rate
  calculateRetentionRate(totalUsers: number, activeUsers: number): void {
    const retentionRate = (activeUsers / totalUsers) * 100;
    
    this.registry.gauge('retention_rate_percentage', {
      value: retentionRate,
      labels: { period: 'monthly' }
    });
  }

  // Track feature adoption
  trackFeatureAdoption(featureName: string, totalUsers: number, usersWithAccess: number): void {
    const adoptionRate = (usersWithAccess / totalUsers) * 100;
    
    this.registry.gauge('feature_adoption_rate', {
      value: adoptionRate,
      labels: { feature: featureName }
    });
  }
}
```

### Metric Labeling Strategy

```typescript
// Best practices for labels
const LABEL_STRATEGIES = {
  // GOOD: Low cardinality
  user_tier: ['free', 'premium', 'enterprise'],
  region: ['us-east', 'us-west', 'eu-west', 'ap-southeast'],
  
  // BAD: High cardinality (avoid)
  // user_id: 'unique-id-for-each-user',  // Don't do this!
  // session_id: 'unique-session-id',     // Don't do this!
  
  // GOOD: Controlled categorization
  plan_type: ['basic', 'pro', 'business'],
  device_type: ['mobile', 'desktop', 'tablet'],
  error_type: ['validation', 'network', 'database', 'unknown']
};

// Use hash-based labels for high-cardinality data
function hashUserId(userId: string): string {
  const hash = userId.split('').reduce((acc, char) => {
    return ((acc << 5) - acc) + char.charCodeAt(0);
  }, 0);
  return `user_${Math.abs(hash) % 1000}`;
}
```

---

## Real-Time Dashboards

Real-time dashboards provide instant visibility into your application's performance and user activity.

### Setting Up Real-Time Metrics

```typescript
import { RealTimeMetrics } from '@nip/analytics/realtime';

class DashboardManager {
  private rtMetrics: RealTimeMetrics;

  constructor() {
    this.rtMetrics = new RealTimeMetrics({
      updateInterval: 1000,  // Update every second
      bufferSize: 300        // Keep 5 minutes of data
    });
  }

  // Track active users in real-time
  trackActiveUsers(): void {
    this.rtMetrics.gauge('active_users_realtime', {
      getValue: async () => {
        return await this.getActiveUserCount();
      }
    });
  }

  // Track request rates
  trackRequestRates(): void {
    this.rtMetrics.counter('requests_per_second', {
      timeWindow: 1000  // Reset every second
    });
  }

  // Track error rates
  trackErrorRates(): void {
    this.rtMetrics.gauge('error_rate_percentage', {
      getValue: async () => {
        const requests = await this.getRequestCount(60000);
        const errors = await this.getErrorCount(60000);
        return (errors / requests) * 100;
      }
    });
  }

  // Track response times
  trackResponseTimes(): void {
    this.rtMetrics.histogram('response_time_ms', {
      buckets: [10, 50, 100, 200, 500, 1000, 2000, 5000],
      timeWindow: 60000  // 1 minute window
    });
  }

  private async getActiveUserCount(): Promise<number> {
    // Implementation depends on your session storage
    return 0;
  }

  private async getRequestCount(windowMs: number): Promise<number> {
    return 0;
  }

  private async getErrorCount(windowMs: number): Promise<number> {
    return 0;
  }
}
```

### WebSocket-Based Live Updates

```typescript
import { WebSocketServer } from 'ws';

class LiveDashboardService {
  private wss: WebSocketServer;
  private metrics: DashboardManager;

  constructor(port: number, metrics: DashboardManager) {
    this.metrics = metrics;
    this.wss = new WebSocketServer({ port });
    this.setupWebSocketServer();
  }

  private setupWebSocketServer(): void {
    this.wss.on('connection', (ws) => {
      console.log('New dashboard client connected');

      // Send initial data
      this.sendDashboardUpdate(ws);

      // Set up periodic updates
      const interval = setInterval(() => {
        this.sendDashboardUpdate(ws);
      }, 1000);

      ws.on('close', () => {
        clearInterval(interval);
        console.log('Dashboard client disconnected');
      });
    });
  }

  private async sendDashboardUpdate(ws: WebSocket): Promise<void> {
    const update = {
      timestamp: Date.now(),
      activeUsers: await this.metrics.getActiveUsers(),
      requestRate: await this.metrics.getRequestRate(),
      errorRate: await this.metrics.getErrorRate(),
      avgResponseTime: await this.metrics.getAverageResponseTime(),
      cpuUsage: await this.metrics.getCpuUsage(),
      memoryUsage: await this.metrics.getMemoryUsage()
    };

    ws.send(JSON.stringify(update));
  }

  private async getActiveUsers(): Promise<number> {
    return Math.floor(Math.random() * 1000) + 500;
  }

  private async getRequestRate(): Promise<number> {
    return Math.floor(Math.random() * 500) + 100;
  }

  private async getErrorRate(): Promise<number> {
    return Math.random() * 5;
  }

  private async getAverageResponseTime(): Promise<number> {
    return Math.random() * 200 + 50;
  }

  private async getCpuUsage(): Promise<number> {
    return Math.random() * 80 + 10;
  }

  private async getMemoryUsage(): Promise<number> {
    return Math.random() * 70 + 20;
  }
}
```

### Dashboard Component Example

```typescript
// React component for real-time metrics
import React, { useState, useEffect } from 'react';

interface DashboardData {
  timestamp: number;
  activeUsers: number;
  requestRate: number;
  errorRate: number;
  avgResponseTime: number;
  cpuUsage: number;
  memoryUsage: number;
}

export const RealTimeDashboard: React.FC = () => {
  const [data, setData] = useState<DashboardData | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    const ws = new WebSocket('ws://localhost:8080');

    ws.onopen = () => {
      setIsConnected(true);
      console.log('Connected to dashboard');
    };

    ws.onmessage = (event) => {
      const update = JSON.parse(event.data);
      setData(update);
    };

    ws.onclose = () => {
      setIsConnected(false);
      console.log('Disconnected from dashboard');
    };

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    return () => {
      ws.close();
    };
  }, []);

  if (!data) {
    return <div>Loading dashboard...</div>;
  }

  return (
    <div className="dashboard">
      <h1>Real-Time Dashboard</h1>
      <div className="status">
        Status: {isConnected ? '🟢 Connected' : '🔴 Disconnected'}
      </div>

      <div className="metrics-grid">
        <MetricCard
          title="Active Users"
          value={data.activeUsers}
          unit="users"
          trend="up"
        />
        <MetricCard
          title="Request Rate"
          value={data.requestRate}
          unit="req/s"
          trend="stable"
        />
        <MetricCard
          title="Error Rate"
          value={data.errorRate}
          unit="%"
          trend={data.errorRate > 1 ? 'up' : 'down'}
          warning={data.errorRate > 1}
        />
        <MetricCard
          title="Avg Response Time"
          value={data.avgResponseTime}
          unit="ms"
          trend={data.avgResponseTime > 200 ? 'up' : 'down'}
        />
        <MetricCard
          title="CPU Usage"
          value={data.cpuUsage}
          unit="%"
          warning={data.cpuUsage > 80}
        />
        <MetricCard
          title="Memory Usage"
          value={data.memoryUsage}
          unit="%"
          warning={data.memoryUsage > 85}
        />
      </div>

      <div className="timestamp">
        Last updated: {new Date(data.timestamp).toLocaleTimeString()}
      </div>
    </div>
  );
};

interface MetricCardProps {
  title: string;
  value: number;
  unit: string;
  trend?: 'up' | 'down' | 'stable';
  warning?: boolean;
}

const MetricCard: React.FC<MetricCardProps> = ({
  title,
  value,
  unit,
  trend,
  warning
}) => {
  const trendIcon = trend === 'up' ? '📈' : trend === 'down' ? '📉' : '➡️';

  return (
    <div className={`metric-card ${warning ? 'warning' : ''}`}>
      <div className="metric-title">{title}</div>
      <div className="metric-value">
        {value.toFixed(1)} <span className="unit">{unit}</span>
      </div>
      {trend && <div className="metric-trend">{trendIcon}</div>}
    </div>
  );
};
```

---

## Data Visualization

Effective data visualization helps identify patterns and trends quickly.

### Time Series Charts

```typescript
import { ChartRenderer } from '@nip/analytics/charts';

class TimeSeriesVisualization {
  private renderer: ChartRenderer;

  constructor() {
    this.renderer = new ChartRenderer();
  }

  // Create a line chart for metrics over time
  async createTimeSeriesChart(metricName: string, timeRange: string): Promise<Buffer> {
    const data = await this.fetchTimeSeriesData(metricName, timeRange);

    const chart = this.renderer.createLineChart({
      title: `${metricName} over ${timeRange}`,
      xAxis: data.timestamps,
      datasets: [
        {
          label: metricName,
          data: data.values,
          borderColor: 'rgb(75, 192, 192)',
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          tension: 0.4
        }
      ],
      yAxis: {
        label: metricName,
        min: 0
      },
      annotations: {
        alertThreshold: {
          value: this.getAlertThreshold(metricName),
          color: 'red',
          label: 'Alert Threshold'
        }
      }
    });

    return chart.toBuffer();
  }

  // Create multi-metric comparison chart
  async createComparisonChart(metrics: string[], timeRange: string): Promise<Buffer> {
    const datasets = await Promise.all(
      metrics.map(async (metric) => {
        const data = await this.fetchTimeSeriesData(metric, timeRange);
        return {
          label: metric,
          data: data.values,
          borderColor: this.getColor(metric),
          tension: 0.4
        };
      })
    );

    const chart = this.renderer.createLineChart({
      title: 'Metrics Comparison',
      xAxis: (await this.fetchTimeSeriesData(metrics[0], timeRange)).timestamps,
      datasets,
      yAxis: {
        label: 'Value'
      }
    });

    return chart.toBuffer();
  }

  private async fetchTimeSeriesData(metric: string, timeRange: string): Promise<any> {
    // Implementation to fetch from your metrics store
    return {
      timestamps: [],
      values: []
    };
  }

  private getAlertThreshold(metric: string): number {
    const thresholds: Record<string, number> = {
      'error_rate': 5.0,
      'response_time': 1000,
      'cpu_usage': 80.0
    };
    return thresholds[metric] || 0;
  }

  private getColor(metric: string): string {
    const colors = [
      'rgb(255, 99, 132)',
      'rgb(54, 162, 235)',
      'rgb(255, 206, 86)',
      'rgb(75, 192, 192)',
      'rgb(153, 102, 255)'
    ];
    const hash = metric.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
    return colors[hash % colors.length];
  }
}
```

### Heatmap Visualization

```typescript
class HeatmapVisualization {
  private renderer: ChartRenderer;

  constructor() {
    this.renderer = new ChartRenderer();
  }

  // Create a heatmap for request density
  async createRequestDensityHeatmap(days: number): Promise<Buffer> {
    const data = await this.fetchRequestDensity(days);

    const chart = this.renderer.createHeatmap({
      title: 'Request Density Heatmap',
      xAxis: {
        label: 'Hour of Day',
        categories: Array.from({ length: 24 }, (_, i) => `${i}:00`)
      },
      yAxis: {
        label: 'Day of Week',
        categories: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
      },
      data: data,
      colorScale: {
        min: '#ffffff',
        max: '#ff6b6b'
      }
    });

    return chart.toBuffer();
  }

  // Create a heatmap for error distribution
  async createErrorDistributionHeatmap(): Promise<Buffer> {
    const data = await this.fetchErrorDistribution();

    const chart = this.renderer.createHeatmap({
      title: 'Error Distribution by Service',
      xAxis: {
        label: 'Service',
        categories: data.services
      },
      yAxis: {
        label: 'Error Type',
        categories: data.errorTypes
      },
      data: data.matrix,
      colorScale: {
        min: '#ffffff',
        max: '#c92a2a'
      }
    });

    return chart.toBuffer();
  }

  private async fetchRequestDensity(days: number): Promise<number[][]> {
    // Returns 7x24 matrix (days x hours)
    const matrix: number[][] = [];
    for (let day = 0; day < 7; day++) {
      matrix[day] = [];
      for (let hour = 0; hour < 24; hour++) {
        matrix[day][hour] = Math.floor(Math.random() * 1000);
      }
    }
    return matrix;
  }

  private async fetchErrorDistribution(): Promise<any> {
    return {
      services: ['auth', 'api', 'db', 'cache', 'queue'],
      errorTypes: ['timeout', '500', '400', 'conn', 'other'],
      matrix: [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]
    };
  }
}
```

---

## Event Tracking

Event tracking captures user actions and system events for analysis.

### Event Tracking Implementation

```typescript
import { EventTracker } from '@nip/analytics/events';

interface UserEvent {
  userId: string;
  eventType: string;
  properties: Record<string, any>;
  timestamp: number;
}

class ComprehensiveEventTracker {
  private tracker: EventTracker;

  constructor() {
    this.tracker = new EventTracker({
      batchSize: 100,
      flushInterval: 5000,
      storagePath: './events'
    });
  }

  // Track page views
  trackPageView(userId: string, page: string, referrer?: string): void {
    this.tracker.track({
      userId,
      eventType: 'page_view',
      properties: {
        page,
        referrer,
        userAgent: navigator.userAgent,
        viewport: {
          width: window.innerWidth,
          height: window.innerHeight
        }
      },
      timestamp: Date.now()
    });
  }

  // Track button clicks
  trackButtonClick(userId: string, buttonId: string, context: string): void {
    this.tracker.track({
      userId,
      eventType: 'button_click',
      properties: {
        buttonId,
        context,
        page: window.location.pathname
      },
      timestamp: Date.now()
    });
  }

  // Track form submissions
  trackFormSubmission(userId: string, formId: string, success: boolean, errors?: string[]): void {
    this.tracker.track({
      userId,
      eventType: 'form_submit',
      properties: {
        formId,
        success,
        errorCount: errors?.length || 0,
        errorTypes: errors
      },
      timestamp: Date.now()
    });
  }

  // Track feature usage
  trackFeatureUsage(userId: string, feature: string, action: string, metadata?: Record<string, any>): void {
    this.tracker.track({
      userId,
      eventType: 'feature_usage',
      properties: {
        feature,
        action,
        ...metadata
      },
      timestamp: Date.now()
    });
  }

  // Track search queries
  trackSearch(userId: string, query: string, resultsCount: number, clickedResult?: string): void {
    this.tracker.track({
      userId,
      eventType: 'search',
      properties: {
        query,
        resultsCount,
        clickedResult,
        queryLength: query.length
      },
      timestamp: Date.now()
    });
  }

  // Track errors
  trackError(userId: string | null, error: Error, context: Record<string, any>): void {
    this.tracker.track({
      userId: userId || 'anonymous',
      eventType: 'error',
      properties: {
        errorMessage: error.message,
        errorStack: error.stack,
        errorName: error.name,
        ...context
      },
      timestamp: Date.now()
    });
  }

  // Track performance metrics
  trackPerformance(userId: string, metricName: string, value: number, unit: string): void {
    this.tracker.track({
      userId,
      eventType: 'performance',
      properties: {
        metricName,
        value,
        unit
      },
      timestamp: Date.now()
    });
  }
}
```

### Event Aggregation

```typescript
class EventAggregator {
  private tracker: EventTracker;

  constructor(tracker: EventTracker) {
    this.tracker = tracker;
  }

  // Aggregate events by type
  async aggregateByEventType(timeRange: { start: number; end: number }): Promise<Record<string, number>> {
    const events = await this.tracker.query({
      startTime: timeRange.start,
      endTime: timeRange.end
    });

    const aggregated: Record<string, number> = {};

    for (const event of events) {
      aggregated[event.eventType] = (aggregated[event.eventType] || 0) + 1;
    }

    return aggregated;
  }

  // Aggregate events by user
  async aggregateByUser(timeRange: { start: number; end: number }): Promise<Record<string, number>> {
    const events = await this.tracker.query({
      startTime: timeRange.start,
      endTime: timeRange.end
    });

    const aggregated: Record<string, number> = {};

    for (const event of events) {
      aggregated[event.userId] = (aggregated[event.userId] || 0) + 1;
    }

    return aggregated;
  }

  // Find most active users
  async getMostActiveUsers(timeRange: { start: number; end: number }, limit: number = 10): Promise<Array<{ userId: string; eventCount: number }>> {
    const byUser = await this.aggregateByUser(timeRange);

    return Object.entries(byUser)
      .map(([userId, eventCount]) => ({ userId, eventCount }))
      .sort((a, b) => b.eventCount - a.eventCount)
      .slice(0, limit);
  }

  // Calculate user session statistics
  async calculateSessionStats(userId: string): Promise<{
    sessionCount: number;
    avgSessionDuration: number;
    totalEvents: number;
    avgEventsPerSession: number;
  }> {
    const events = await this.tracker.query({
      filters: { userId }
    });

    // Group events into sessions (30-minute gap = new session)
    const sessions: number[][] = [];
    let currentSession: number[] = [];

    for (const event of events.sort((a, b) => a.timestamp - b.timestamp)) {
      if (currentSession.length === 0) {
        currentSession.push(event.timestamp);
      } else {
        const lastEvent = currentSession[currentSession.length - 1];
        if (event.timestamp - lastEvent > 30 * 60 * 1000) {
          sessions.push(currentSession);
          currentSession = [event.timestamp];
        } else {
          currentSession.push(event.timestamp);
        }
      }
    }

    if (currentSession.length > 0) {
      sessions.push(currentSession);
    }

    // Calculate statistics
    const sessionDurations = sessions.map(session => 
      session[session.length - 1] - session[0]
    );

    return {
      sessionCount: sessions.length,
      avgSessionDuration: sessionDurations.reduce((a, b) => a + b, 0) / sessions.length,
      totalEvents: events.length,
      avgEventsPerSession: events.length / sessions.length
    };
  }
}
```

---

## Funnel Analysis

Funnel analysis helps identify where users drop off in conversion processes.

### Funnel Tracking Implementation

```typescript
interface FunnelStep {
  name: string;
  event: string;
  conditions?: (event: UserEvent) => boolean;
}

interface FunnelConfig {
  name: string;
  steps: FunnelStep[];
  timeWindow?: number;  // Max time between steps in ms
}

class FunnelAnalyzer {
  private tracker: EventTracker;
  private funnels: Map<string, FunnelConfig>;

  constructor(tracker: EventTracker) {
    this.tracker = tracker;
    this.funnels = new Map();
  }

  // Define a funnel
  defineFunnel(config: FunnelConfig): void {
    this.funnels.set(config.name, config);
  }

  // Analyze funnel performance
  async analyzeFunnel(funnelName: string, timeRange: { start: number; end: number }): Promise<{
    funnelName: string;
    totalUsers: number;
    steps: Array<{
      name: string;
      count: number;
      percentage: number;
      dropoff: number;
      dropoffPercentage: number
    }>;
    overallConversionRate: number;
  }> {
    const funnel = this.funnels.get(funnelName);
    if (!funnel) {
      throw new Error(`Funnel ${funnelName} not found`);
    }

    const events = await this.tracker.query({
      startTime: timeRange.start,
      endTime: timeRange.end
    });

    // Get unique users who entered the funnel
    const firstStepEvents = events.filter(e => 
      e.eventType === funnel.steps[0].event &&
      (!funnel.steps[0].conditions || funnel.steps[0].conditions(e))
    );

    const uniqueUsers = Array.from(new Set(firstStepEvents.map(e => e.userId)));
    const stepCounts = new Array(funnel.steps.length).fill(0);

    // Count users who completed each step
    for (const userId of uniqueUsers) {
      const userEvents = events.filter(e => e.userId === userId).sort((a, b) => a.timestamp - b.timestamp);

      let currentStep = 0;
      let stepTimestamp = 0;

      for (const event of userEvents) {
        if (currentStep >= funnel.steps.length) break;

        const step = funnel.steps[currentStep];
        if (event.eventType === step.event && (!step.conditions || step.conditions(event))) {
          if (funnel.timeWindow && stepTimestamp > 0 && event.timestamp - stepTimestamp > funnel.timeWindow) {
            // Time window exceeded, stop tracking this user
            break;
          }
          stepCounts[currentStep]++;
          stepTimestamp = event.timestamp;
          currentStep++;
        }
      }
    }

    // Calculate percentages
    const totalUsers = uniqueUsers.length;
    const steps = funnel.steps.map((step, index) => {
      const count = stepCounts[index];
      const percentage = (count / totalUsers) * 100;
      const dropoff = index > 0 ? stepCounts[index - 1] - count : totalUsers - count;
      const dropoffPercentage = index > 0 
        ? ((stepCounts[index - 1] - count) / stepCounts[index - 1]) * 100
        : ((totalUsers - count) / totalUsers) * 100;

      return {
        name: step.name,
        count,
        percentage,
        dropoff,
        dropoffPercentage
      };
    });

    const overallConversionRate = (stepCounts[stepCounts.length - 1] / totalUsers) * 100;

    return {
      funnelName,
      totalUsers,
      steps,
      overallConversionRate
    };
  }
}

// Example: Define and analyze a checkout funnel
const funnelAnalyzer = new FunnelAnalyzer(eventTracker);

funnelAnalyzer.defineFunnel({
  name: 'checkout_funnel',
  steps: [
    { name: 'View Product', event: 'product_view' },
    { name: 'Add to Cart', event: 'add_to_cart' },
    { name: 'Begin Checkout', event: 'checkout_start' },
    { name: 'Enter Shipping', event: 'shipping_info_entered' },
    { name: 'Enter Payment', event: 'payment_info_entered' },
    { name: 'Complete Purchase', event: 'purchase_complete' }
  ],
  timeWindow: 24 * 60 * 60 * 1000  // 24 hours
});

// Analyze the funnel
const analysis = await funnelAnalyzer.analyzeFunnel('checkout_funnel', {
  start: Date.now() - 7 * 24 * 60 * 60 * 1000,  // Last 7 days
  end: Date.now()
});

console.log('Funnel Analysis:', analysis);
```

### Funnel Visualization

```typescript
class FunnelVisualizer {
  private renderer: ChartRenderer;

  constructor() {
    this.renderer = new ChartRenderer();
  }

  async createFunnelChart(analysis: Awaited<ReturnType<FunnelAnalyzer['analyzeFunnel']>>): Promise<Buffer> {
    const chart = this.renderer.createFunnelChart({
      title: analysis.funnelName,
      data: analysis.steps.map(step => ({
        label: step.name,
        value: step.count,
        percentage: step.percentage
      })),
      colors: [
        '#4dabf7',
        '#339af0',
        '#228be6',
        '#1c7ed6',
        '#1971c2',
        '#1864ab'
      ],
      annotations: {
        overallConversion: `${analysis.overallConversionRate.toFixed(1)}%`
      }
    });

    return chart.toBuffer();
  }

  async createFunnelComparison(funnelName: string, ...periods: Array<{ label: string; start: number; end: number }>): Promise<Buffer> {
    const analyses = await Promise.all(
      periods.map(period => funnelAnalyzer.analyzeFunnel(funnelName, period))
    );

    const chart = this.renderer.createMultiSeriesFunnel({
      title: `Funnel Comparison: ${funnelName}`,
      series: analyses.map((analysis, index) => ({
        label: periods[index].label,
        data: analysis.steps.map(step => step.count)
      })),
      labels: analyses[0].steps.map(step => step.name)
    });

    return chart.toBuffer();
  }
}
```

---

## Cohort Analysis

Cohort analysis tracks groups of users over time to understand retention and behavior patterns.

### Cohort Definition and Tracking

```typescript
interface CohortDefinition {
  name: string;
  groupingProperty: string;
  timeGranularity: 'day' | 'week' | 'month';
}

interface CohortData {
  cohort: string;
  period: number;
  userCount: number;
  activeCount: number;
  retentionRate: number;
}

class CohortAnalyzer {
  private tracker: EventTracker;

  constructor(tracker: EventTracker) {
    this.tracker = tracker;
  }

  // Create a cohort based on user acquisition date
  async analyzeRetentionCohort(
    startDate: number,
    endDate: number,
    periods: number = 12
  ): Promise<CohortData[]> {
    // Get all users who signed up in the date range
    const signupEvents = await this.tracker.query({
      filters: { eventType: 'user_signup' },
      startTime: startDate,
      endTime: endDate
    });

    // Group users by signup date (weekly cohorts)
    const cohorts: Record<string, string[]> = {};
    for (const event of signupEvents) {
      const week = this.getWeekNumber(event.timestamp);
      if (!cohorts[week]) {
        cohorts[week] = [];
      }
      cohorts[week].push(event.userId);
    }

    // Calculate retention for each cohort over time
    const results: CohortData[] = [];

    for (const [cohortWeek, users] of Object.entries(cohorts)) {
      const cohortStart = this.parseWeekNumber(cohortWeek);

      for (let period = 0; period < periods; period++) {
        const periodStart = cohortStart + (period * 7 * 24 * 60 * 60 * 1000);
        const periodEnd = periodStart + (7 * 24 * 60 * 60 * 1000);

        // Count active users in this period
        const activeUsers = new Set<string>();

        const activityEvents = await this.tracker.query({
          startTime: periodStart,
          endTime: periodEnd,
          filters: { eventType: 'page_view' }
        });

        for (const event of activityEvents) {
          if (users.includes(event.userId)) {
            activeUsers.add(event.userId);
          }
        }

        results.push({
          cohort: cohortWeek,
          period,
          userCount: users.length,
          activeCount: activeUsers.size,
          retentionRate: (activeUsers.size / users.length) * 100
        });
      }
    }

    return results;
  }

  // Analyze behavioral cohorts (e.g., users who performed a specific action)
  async analyzeBehavioralCohort(
    triggerEvent: string,
    startDate: number,
    endDate: number
  ): Promise<CohortData[]> {
    // Get users who performed the trigger action
    const triggerEvents = await this.tracker.query({
      filters: { eventType: triggerEvent },
      startTime: startDate,
      endTime: endDate
    });

    const cohorts: Record<string, { users: Set<string>; date: number }> = {};

    for (const event of triggerEvents) {
      const week = this.getWeekNumber(event.timestamp);
      if (!cohorts[week]) {
        cohorts[week] = { users: new Set(), date: event.timestamp };
      }
      cohorts[week].users.add(event.userId);
    }

    const results: CohortData[] = [];

    for (const [cohortWeek, data] of Object.entries(cohorts)) {
      // Track subsequent behavior
      for (let period = 0; period < 8; period++) {
        const periodStart = data.date + (period * 7 * 24 * 60 * 60 * 1000);
        const periodEnd = periodStart + (7 * 24 * 60 * 60 * 1000);

        const activeUsers = new Set<string>();

        const events = await this.tracker.query({
          startTime: periodStart,
          endTime: periodEnd
        });

        for (const event of events) {
          if (data.users.has(event.userId)) {
            activeUsers.add(event.userId);
          }
        }

        results.push({
          cohort: cohortWeek,
          period,
          userCount: data.users.size,
          activeCount: activeUsers.size,
          retentionRate: (activeUsers.size / data.users.size) * 100
        });
      }
    }

    return results;
  }

  private getWeekNumber(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const week = Math.floor((date.getTime() - new Date(year, 0, 1).getTime()) / (7 * 24 * 60 * 60 * 1000));
    return `${year}-W${week.toString().padStart(2, '0')}`;
  }

  private parseWeekNumber(weekStr: string): number {
    const [year, week] = weekStr.split('-W');
    return new Date(parseInt(year), 0, 1 + (parseInt(week) * 7)).getTime();
  }
}
```

### Cohort Visualization

```typescript
class CohortVisualizer {
  private renderer: ChartRenderer;

  constructor() {
    this.renderer = new ChartRenderer();
  }

  async createRetentionHeatmap(cohortData: CohortData[]): Promise<Buffer> {
    // Organize data for heatmap
    const cohorts = Array.from(new Set(cohortData.map(d => d.cohort))).sort();
    const periods = Array.from(new Set(cohortData.map(d => d.period))).sort();

    const matrix: number[][] = [];
    for (const cohort of cohorts) {
      const row: number[] = [];
      for (const period of periods) {
        const dataPoint = cohortData.find(d => d.cohort === cohort && d.period === period);
        row.push(dataPoint ? dataPoint.retentionRate : 0);
      }
      matrix.push(row);
    }

    const chart = this.renderer.createHeatmap({
      title: 'User Retention by Cohort',
      xAxis: {
        label: 'Period',
        categories: periods.map(p => `Week ${p}`)
      },
      yAxis: {
        label: 'Cohort',
        categories: cohorts
      },
      data: matrix,
      colorScale: {
        min: '#ffffff',
        max: '#339af0'
      }
    });

    return chart.toBuffer();
  }

  async createCohortComparison(cohortData: CohortData[]): Promise<Buffer> {
    const cohorts = Array.from(new Set(cohortData.map(d => d.cohort))).sort();

    const datasets = cohorts.map(cohort => {
      const cohortPoints = cohortData
        .filter(d => d.cohort === cohort)
        .sort((a, b) => a.period - b.period);

      return {
        label: cohort,
        data: cohortPoints.map(p => p.retentionRate),
        borderColor: this.getColor(cohort),
        tension: 0.4
      };
    });

    const chart = this.renderer.createLineChart({
      title: 'Retention Rate Comparison',
      xAxis: {
        label: 'Period (weeks)',
        categories: Array.from(new Set(cohortData.map(d => d.period))).sort()
      },
      datasets,
      yAxis: {
        label: 'Retention Rate (%)',
        min: 0,
        max: 100
      }
    });

    return chart.toBuffer();
  }

  private getColor(cohort: string): string {
    const hash = cohort.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
    const colors = [
      '#4dabf7',
      '#339af0',
      '#228be6',
      '#1c7ed6',
      '#1971c2',
      '#1864ab',
      '#4c6ef5',
      '#3b5bdb'
    ];
    return colors[hash % colors.length];
  }
}
```

---

## Predictive Analytics

Predictive analytics uses historical data to forecast future trends and outcomes.

### Predictive Models

```typescript
import { RegressionModel, TimeSeriesForecast } from '@nip/analytics/predictive';

class PredictiveAnalytics {
  private models: Map<string, RegressionModel>;

  constructor() {
    this.models = new Map();
  }

  // Train a model to predict user growth
  async trainUserGrowthModel(historicalData: Array<{ date: number; users: number }>): Promise<RegressionModel> {
    const model = new RegressionModel({
      type: 'linear',
      features: ['time']
    });

    // Prepare training data
    const trainingData = historicalData.map((point, index) => ({
      features: { time: index },
      target: point.users
    }));

    await model.train(trainingData);

    this.models.set('user_growth', model);
    return model;
  }

  // Predict future user growth
  predictUserGrowth(daysAhead: number): number[] {
    const model = this.models.get('user_growth');
    if (!model) {
      throw new Error('User growth model not trained');
    }

    const predictions: number[] = [];
    const currentTime = Date.now();

    for (let i = 1; i <= daysAhead; i++) {
      const prediction = model.predict({ time: i });
      predictions.push(prediction);
    }

    return predictions;
  }

  // Train a model to predict churn
  async trainChurnModel(userData: Array<{
    userId: string;
    features: {
      sessionCount: number;
      avgSessionDuration: number;
      lastLoginDaysAgo: number;
      featureUsageScore: number
    };
    churned: boolean
  }>): Promise<RegressionModel> {
    const model = new RegressionModel({
      type: 'logistic',
      features: ['sessionCount', 'avgSessionDuration', 'lastLoginDaysAgo', 'featureUsageScore']
    });

    const trainingData = userData.map(user => ({
      features: user.features,
      target: user.churned ? 1 : 0
    }));

    await model.train(trainingData);

    this.models.set('churn_prediction', model);
    return model;
  }

  // Predict churn risk for a user
  predictChurnRisk(userId: string, features: {
    sessionCount: number;
    avgSessionDuration: number;
    lastLoginDaysAgo: number;
    featureUsageScore: number
  }): number {
    const model = this.models.get('churn_prediction');
    if (!model) {
      throw new Error('Churn model not trained');
    }

    const churnProbability = model.predict(features);
    return churnProbability;
  }

  // Identify at-risk users
  async identifyAtRiskUsers(userFeatures: Array<{
    userId: string;
    features: {
      sessionCount: number;
      avgSessionDuration: number;
      lastLoginDaysAgo: number;
      featureUsageScore: number
    }
  }>, threshold: number = 0.5): Promise<Array<{ userId: string; risk: number }>> {
    const atRiskUsers: Array<{ userId: string; risk: number }> = [];

    for (const user of userFeatures) {
      const risk = this.predictChurnRisk(user.userId, user.features);
      if (risk >= threshold) {
        atRiskUsers.push({ userId: user.userId, risk });
      }
    }

    return atRiskUsers.sort((a, b) => b.risk - a.risk);
  }

  // Forecast revenue
  async forecastRevenue(historicalData: Array<{ date: number; revenue: number }>, periods: number = 12): Promise<number[]> {
    const forecast = new TimeSeriesForecast({
      method: 'exponential_smoothing',
      alpha: 0.3,
      beta: 0.1,
      seasonLength: 12
    });

    await forecast.train(historicalData.map(d => d.revenue));

    const predictions = await forecast.predict(periods);
    return predictions;
  }

  // Detect anomalies in metrics
  async detectAnomalies(metricData: number[], threshold: number = 2): Promise<Array<{ index: number; value: number; score: number }>> {
    const mean = metricData.reduce((a, b) => a + b, 0) / metricData.length;
    const variance = metricData.reduce((a, b) => a + Math.pow(b - mean, 2), 0) / metricData.length;
    const stdDev = Math.sqrt(variance);

    const anomalies: Array<{ index: number; value: number; score: number }> = [];

    for (let i = 0; i < metricData.length; i++) {
      const zScore = Math.abs((metricData[i] - mean) / stdDev);
      if (zScore > threshold) {
        anomalies.push({
          index: i,
          value: metricData[i],
          score: zScore
        });
      }
    }

    return anomalies;
  }
}
```

### Predictive Analytics Dashboard

```typescript
class PredictiveDashboard {
  private predictor: PredictiveAnalytics;
  private tracker: EventTracker;

  constructor(predictor: PredictiveAnalytics, tracker: EventTracker) {
    this.predictor = predictor;
    this.tracker = tracker;
  }

  async generatePredictiveReport(): Promise<{
    userGrowthForecast: number[];
    revenueForecast: number[];
    atRiskUsers: Array<{ userId: string; risk: number }>;
    anomalies: Array<{ metric: string; anomalies: any[] }>;
  }> {
    // Get historical data
    const userHistory = await this.getUserHistory();
    const revenueHistory = await this.getRevenueHistory();
    const userFeatures = await this.getUserFeatures();

    // Train models (in production, train periodically, not on every request)
    await this.predictor.trainUserGrowthModel(userHistory);
    await this.predictor.trainChurnModel(await this.getChurnTrainingData());

    // Generate predictions
    const userGrowthForecast = this.predictor.predictUserGrowth(30);
    const revenueForecast = await this.predictor.forecastRevenue(revenueHistory, 12);
    const atRiskUsers = await this.predictor.identifyAtRiskUsers(userFeatures, 0.6);

    // Detect anomalies
    const anomalies = [
      {
        metric: 'request_rate',
        anomalies: await this.predictor.detectAnomalies(await this.getRequestRateHistory())
      },
      {
        metric: 'error_rate',
        anomalies: await this.predictor.detectAnomalies(await this.getErrorRateHistory())
      }
    ];

    return {
      userGrowthForecast,
      revenueForecast,
      atRiskUsers,
      anomalies
    };
  }

  private async getUserHistory(): Promise<Array<{ date: number; users: number }>> {
    const events = await this.tracker.query({
      filters: { eventType: 'daily_user_count' },
      startTime: Date.now() - 90 * 24 * 60 * 60 * 1000,
      endTime: Date.now()
    });

    return events.map(e => ({
      date: e.timestamp,
      users: e.properties.count
    }));
  }

  private async getRevenueHistory(): Promise<Array<{ date: number; revenue: number }>> {
    // Implementation depends on your revenue tracking
    return [];
  }

  private async getUserFeatures(): Promise<Array<{ userId: string; features: any }>> {
    // Implementation depends on your user data
    return [];
  }

  private async getChurnTrainingData(): Promise<any> {
    // Implementation depends on your churn data
    return [];
  }

  private async getRequestRateHistory(): Promise<number[]> {
    // Implementation
    return [];
  }

  private async getErrorRateHistory(): Promise<number[]> {
    // Implementation
    return [];
  }
}
```

---

## Alerting and Notifications

Alerts notify you of important events and threshold breaches.

### Alert System

```typescript
interface AlertRule {
  id: string;
  name: string;
  metric: string;
  condition: 'above' | 'below' | 'equals' | 'changes_by';
  threshold: number;
  severity: 'info' | 'warning' | 'critical';
  cooldown: number;  // Minimum time between alerts in ms
}

interface Alert {
  ruleId: string;
  ruleName: string;
  severity: string;
  message: string;
  timestamp: number;
  value: number;
}

class AlertManager {
  private rules: Map<string, AlertRule>;
  private lastAlertTime: Map<string, number>;
  private notifiers: Map<string, NotificationService>;

  constructor() {
    this.rules = new Map();
    this.lastAlertTime = new Map();
    this.notifiers = new Map();
  }

  // Add an alert rule
  addRule(rule: AlertRule): void {
    this.rules.set(rule.id, rule);
  }

  // Register a notification service
  registerNotifier(name: string, service: NotificationService): void {
    this.notifiers.set(name, service);
  }

  // Evaluate all rules against current metrics
  async evaluateRules(metrics: Map<string, number>): Promise<Alert[]> {
    const alerts: Alert[] = [];
    const now = Date.now();

    for (const rule of this.rules.values()) {
      const value = metrics.get(rule.metric);
      if (value === undefined) continue;

      const shouldAlert = this.checkCondition(value, rule);
      const lastAlert = this.lastAlertTime.get(rule.id) || 0;

      if (shouldAlert && (now - lastAlert) > rule.cooldown) {
        const alert: Alert = {
          ruleId: rule.id,
          ruleName: rule.name,
          severity: rule.severity,
          message: this.formatAlertMessage(rule, value),
          timestamp: now,
          value
        };

        alerts.push(alert);
        this.lastAlertTime.set(rule.id, now);

        // Send notifications
        await this.sendNotifications(alert);
      }
    }

    return alerts;
  }

  private checkCondition(value: number, rule: AlertRule): boolean {
    switch (rule.condition) {
      case 'above':
        return value > rule.threshold;
      case 'below':
        return value < rule.threshold;
      case 'equals':
        return value === rule.threshold;
      case 'changes_by':
        // This requires historical data
        return false;  // Simplified for example
      default:
        return false;
    }
  }

  private formatAlertMessage(rule: AlertRule, value: number): string {
    const operator = rule.condition === 'above' ? 'exceeded' : 'fell below';
    return `${rule.name}: ${rule.metric} ${operator} threshold of ${rule.threshold} (current: ${value.toFixed(2)})`;
  }

  private async sendNotifications(alert: Alert): Promise<void> {
    for (const notifier of this.notifiers.values()) {
      try {
        await notifier.send(alert);
      } catch (error) {
        console.error(`Failed to send notification via ${notifier.name}:`, error);
      }
    }
  }
}

// Notification service interface
interface NotificationService {
  name: string;
  send(alert: Alert): Promise<void>;
}

// Email notification service
class EmailNotifier implements NotificationService {
  name = 'email';

  constructor(private smtpConfig: any) {}

  async send(alert: Alert): Promise<void> {
    // Implementation to send email
    console.log(`Sending email alert: ${alert.message}`);
  }
}

// Slack notification service
class SlackNotifier implements NotificationService {
  name = 'slack';

  constructor(private webhookUrl: string) {}

  async send(alert: Alert): Promise<void> {
    const payload = {
      text: `🚨 ${alert.severity.toUpperCase()} Alert`,
      attachments: [
        {
          color: this.getColor(alert.severity),
          fields: [
            { title: 'Rule', value: alert.ruleName },
            { title: 'Severity', value: alert.severity },
            { title: 'Value', value: alert.value.toString() },
            { title: 'Time', value: new Date(alert.timestamp).toISOString() }
          ]
        }
      ]
    };

    console.log(`Sending Slack alert:`, payload);
    // In production: await fetch(this.webhookUrl, { method: 'POST', body: JSON.stringify(payload) });
  }

  private getColor(severity: string): string {
    const colors = {
      info: '#36a64f',
      warning: '#ff9800',
      critical: '#f44336'
    };
    return colors[severity] || '#36a64f';
  }
}

// PagerDuty notification service
class PagerDutyNotifier implements NotificationService {
  name = 'pagerduty';

  constructor(private integrationKey: string) {}

  async send(alert: Alert): Promise<void> {
    if (alert.severity !== 'critical') {
      return;  // Only send critical alerts to PagerDuty
    }

    const payload = {
      routing_key: this.integrationKey,
      event_action: 'trigger',
      payload: {
        summary: alert.message,
        severity: alert.severity,
        source: 'NIP Analytics',
        timestamp: new Date(alert.timestamp).toISOString(),
        custom_details: {
          rule: alert.ruleName,
          value: alert.value
        }
      }
    };

    console.log(`Sending PagerDuty alert:`, payload);
    // In production: await fetch('https://events.pagerduty.com/v2/enqueue', { method: 'POST', body: JSON.stringify(payload) });
  }
}
```

### Alert Configuration Examples

```typescript
// Set up comprehensive alerting
const alertManager = new AlertManager();

// Register notification services
alertManager.registerNotifier('email', new EmailNotifier(smtpConfig));
alertManager.registerNotifier('slack', new SlackNotifier(process.env.SLACK_WEBHOOK));
alertManager.registerNotifier('pagerduty', new PagerDutyNotifier(process.env.PAGERDUTY_KEY));

// Add alert rules
alertManager.addRule({
  id: 'high-error-rate',
  name: 'High Error Rate',
  metric: 'error_rate_percentage',
  condition: 'above',
  threshold: 5.0,
  severity: 'critical',
  cooldown: 5 * 60 * 1000  // 5 minutes
});

alertManager.addRule({
  id: 'high-response-time',
  name: 'High Response Time',
  metric: 'avg_response_time_ms',
  condition: 'above',
  threshold: 1000,
  severity: 'warning',
  cooldown: 10 * 60 * 1000  // 10 minutes
});

alertManager.addRule({
  id: 'low-active-users',
  name: 'Low Active Users',
  metric: 'active_users',
  condition: 'below',
  threshold: 100,
  severity: 'warning',
  cooldown: 60 * 60 * 1000  // 1 hour
});

alertManager.addRule({
  id: 'high-cpu-usage',
  name: 'High CPU Usage',
  metric: 'cpu_usage_percentage',
  condition: 'above',
  threshold: 90,
  severity: 'critical',
  cooldown: 3 * 60 * 1000  // 3 minutes
});

alertManager.addRule({
  id: 'high-memory-usage',
  name: 'High Memory Usage',
  metric: 'memory_usage_percentage',
  condition: 'above',
  threshold: 85,
  severity: 'warning',
  cooldown: 5 * 60 * 1000  // 5 minutes
});

// Periodic evaluation
setInterval(async () => {
  const currentMetrics = await getCurrentMetrics();
  const alerts = await alertManager.evaluateRules(currentMetrics);

  if (alerts.length > 0) {
    console.log(`Generated ${alerts.length} alerts`);
  }
}, 30000);  // Check every 30 seconds
```

---

## Integration with Grafana/Prometheus

### Prometheus Exporter

```typescript
import { Counter, Gauge, Histogram, Registry } from 'prom-client';

class PrometheusMetricsExporter {
  private registry: Registry;
  private counters: Map<string, Counter>;
  private gauges: Map<string, Gauge>;
  private histograms: Map<string, Histogram>;

  constructor() {
    this.registry = new Registry();
    this.counters = new Map();
    this.gauges = new Map();
    this.histograms = new Map();
  }

  // Register a counter
  registerCounter(name: string, help: string, labelNames: string[]): Counter {
    const counter = new Counter({
      name: `nip_${name}`,
      help,
      labelNames,
      registers: [this.registry]
    });

    this.counters.set(name, counter);
    return counter;
  }

  // Register a gauge
  registerGauge(name: string, help: string, labelNames: string[]): Gauge {
    const gauge = new Gauge({
      name: `nip_${name}`,
      help,
      labelNames,
      registers: [this.registry]
    });

    this.gauges.set(name, gauge);
    return gauge;
  }

  // Register a histogram
  registerHistogram(name: string, help: string, labelNames: string[], buckets?: number[]): Histogram {
    const histogram = new Histogram({
      name: `nip_${name}`,
      help,
      labelNames,
      buckets: buckets || [5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000],
      registers: [this.registry]
    });

    this.histograms.set(name, histogram);
    return histogram;
  }

  // Increment a counter
  incrementCounter(name: string, value: number = 1, labels?: Record<string, string>): void {
    const counter = this.counters.get(name);
    if (counter) {
      if (labels) {
        counter.inc(labels, value);
      } else {
        counter.inc(value);
      }
    }
  }

  // Set a gauge value
  setGauge(name: string, value: number, labels?: Record<string, string>): void {
    const gauge = this.gauges.get(name);
    if (gauge) {
      if (labels) {
        gauge.set(labels, value);
      } else {
        gauge.set(value);
      }
    }
  }

  // Observe a histogram value
  observeHistogram(name: string, value: number, labels?: Record<string, string>): void {
    const histogram = this.histograms.get(name);
    if (histogram) {
      if (labels) {
        histogram.observe(labels, value);
      } else {
        histogram.observe(value);
      }
    }
  }

  // Get metrics for Prometheus scraping
  async getMetrics(): Promise<string> {
    return await this.registry.metrics();
  }

  // Clear all metrics
  clearMetrics(): void {
    this.registry.clear();
    this.counters.clear();
    this.gauges.clear();
    this.histograms.clear();
  }
}

// Express endpoint for Prometheus scraping
import express from 'express';

const app = express();
const exporter = new PrometheusMetricsExporter();

// Register metrics
exporter.registerCounter('http_requests_total', 'Total HTTP requests', ['method', 'route', 'status']);
exporter.registerHistogram('http_request_duration_ms', 'HTTP request duration', ['method', 'route']);
exporter.registerGauge('active_connections', 'Number of active connections', []);

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', this.registry.contentType);
  res.end(await exporter.getMetrics());
});

app.listen(9090, () => {
  console.log('Prometheus exporter listening on port 9090');
});
```

### Grafana Dashboard Configuration

```json
{
  "dashboard": {
    "title": "NIP Advanced Analytics",
    "tags": ["nip", "analytics"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(nip_http_requests_total[5m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ]
      },
      {
        "id": 2,
        "title": "Response Time Percentiles",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.50, rate(nip_http_request_duration_ms_bucket[5m]))",
            "legendFormat": "p50"
          },
          {
            "expr": "histogram_quantile(0.95, rate(nip_http_request_duration_ms_bucket[5m]))",
            "legendFormat": "p95"
          },
          {
            "expr": "histogram_quantile(0.99, rate(nip_http_request_duration_ms_bucket[5m]))",
            "legendFormat": "p99"
          }
        ]
      },
      {
        "id": 3,
        "title": "Active Users",
        "type": "stat",
        "targets": [
          {
            "expr": "nip_active_users",
            "legendFormat": "Active Users"
          }
        ]
      },
      {
        "id": 4,
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(nip_http_requests_total{status=~\"5..\"}[5m]) / rate(nip_http_requests_total[5m]) * 100",
            "legendFormat": "Error Rate %"
          }
        ],
        "alert": {
          "conditions": [
            {
              "evaluator": {
                "params": [5],
                "type": "gt"
              },
              "operator": {
                "type": "and"
              },
              "query": {
                "params": ["A", "5m", "now"]
              },
              "reducer": {
                "params": [],
                "type": "avg"
              },
              "type": "query"
            }
          ]
        }
      },
      {
        "id": 5,
        "title": "Conversion Funnel",
        "type": "bargauge",
        "targets": [
          {
            "expr": "nip_conversion_steps_total{status=\"success\"}",
            "legendFormat": "{{step}}"
          }
        ],
        "options": {
          "orientation": "horizontal",
          "displayMode": "gradient"
        }
      },
      {
        "id": 6,
        "title": "Retention Cohorts",
        "type": "heatmap",
        "targets": [
          {
            "expr": "nip_retention_rate",
            "legendFormat": "{{cohort}}"
          }
        ]
      }
    ]
  }
}
```

### Prometheus Alert Rules

```yaml
# prometheus/alerts.yml
groups:
  - name: nip_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(nip_http_requests_total{status=~"5.."}[5m]) / rate(nip_http_requests_total[5m]) * 100 > 5
        for: 5m
        labels:
          severity: critical
          service: nip
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}% for the last 5 minutes"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(nip_http_request_duration_ms_bucket[5m])) > 1000
        for: 10m
        labels:
          severity: warning
          service: nip
        annotations:
          summary: "High response time detected"
          description: "p95 response time is {{ $value }}ms"

      - alert: LowActiveUsers
        expr: nip_active_users < 100
        for: 15m
        labels:
          severity: warning
          service: nip
        annotations:
          summary: "Low active users"
          description: "Only {{ $value }} active users"

      - alert: HighCpuUsage
        expr: nip_cpu_usage_percentage > 90
        for: 5m
        labels:
          severity: critical
          service: nip
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%"
```

---

## Practical Exercises

### Exercise 1: Custom Metrics Implementation

**Task**: Implement custom metrics for an e-commerce application.

```typescript
// TODO: Implement the following
class ECommerceMetrics {
  // Track orders by payment method
  trackOrder(paymentMethod: string, amount: number): void {
    // Your implementation
  }

  // Track cart abandonment
  trackCartAbandonment(step: string): void {
    // Your implementation
  }

  // Calculate average order value per customer tier
  calculateAOVByTier(tier: string): void {
    // Your implementation
  }
}
```

**Solution**: See the Custom Metrics section above for reference.

### Exercise 2: Funnel Analysis

**Task**: Create and analyze a user registration funnel.

1. Define funnel steps
2. Track events at each step
3. Analyze drop-off rates
4. Identify the biggest drop-off point
5. Propose improvements

### Exercise 3: Predictive Analytics

**Task**: Build a simple churn prediction model.

1. Collect user activity data
2. Define features that predict churn
3. Train a model
4. Predict churn for current users
5. Create targeted retention campaigns

### Exercise 4: Real-Time Dashboard

**Task**: Build a real-time operations dashboard.

1. Track key metrics in real-time
2. Set up WebSocket updates
3. Create visual components
4. Implement alert thresholds
5. Add drill-down capabilities

---

## Best Practices

### Metric Design

1. **Use clear, descriptive names**
   - ✅ `user_registration_total`
   - ❌ `users_reg`

2. **Include units in metric names**
   - ✅ `request_duration_milliseconds`
   - ❌ `request_duration`

3. **Use consistent naming conventions**
   - Use `_total` for counters
   - Use `_bytes`, `_seconds`, etc. for units

4. **Limit label cardinality**
   - Keep label values bounded
   - Avoid high-cardinality labels like user IDs
   - Use categorical labels

### Alert Configuration

1. **Set appropriate thresholds**
   - Avoid alert fatigue
   - Use multiple severity levels
   - Implement cooldown periods

2. **Provide actionable alerts**
   - Include context in alert messages
   - Link to relevant dashboards
   - Suggest potential resolutions

3. **Test alert rules**
   - Verify alerts trigger correctly
   - Check notification delivery
   - Practice incident response

### Dashboard Design

1. **Start with key metrics**
   - Focus on what matters most
   - Avoid information overload
   - Use progressive disclosure

2. **Provide context**
   - Include time ranges
   - Show comparisons (previous period, targets)
   - Use annotations for events

3. **Optimize for performance**
   - Cache expensive queries
   - Use appropriate time ranges
   - Pre-aggregate data when possible

### Data Retention

1. **Define retention policies**
   - Keep raw data for limited time
   - Aggregate for long-term storage
   - Compress historical data

2. **Implement data lifecycle**
   - Hot data: Recent, high resolution
   - Warm data: Medium-term, aggregated
   - Cold data: Long-term, highly aggregated

3. **Consider compliance**
   - GDPR requirements
   - Data privacy regulations
   - User consent management

---

## Summary

This tutorial covered advanced analytics techniques in NIP v3.0.0:

- **Custom Metrics**: Domain-specific tracking for business insights
- **Real-Time Dashboards**: Live monitoring with WebSocket updates
- **Data Visualization**: Charts, heatmaps, and funnel visualizations
- **Event Tracking**: Comprehensive user behavior analysis
- **Funnel Analysis**: Conversion optimization through drop-off analysis
- **Cohort Analysis**: Retention patterns by user segments
- **Predictive Analytics**: Forecasting and anomaly detection
- **Alerting**: Intelligent notifications for critical events
- **Grafana/Prometheus**: Industry-standard monitoring integration

### Next Steps

1. Implement the exercises in this tutorial
2. Set up your Grafana dashboards
3. Configure Prometheus alerting
4. Build custom metrics for your domain
5. Iterate based on insights gained

### Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [NIP Documentation](https://docs.nip.analytics/)
- [Metrics Best Practices](https://docs.google.com/document/d/...)
