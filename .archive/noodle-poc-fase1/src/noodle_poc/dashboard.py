"""
Dashboard generator for visualizing profiling metrics.
Creates interactive HTML reports with charts and statistics.
"""

import json
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
from pathlib import Path
from typing import Dict, Any, Optional, List
from datetime import datetime
import pandas as pd
import numpy as np


class DashboardGenerator:
    """Generate interactive HTML dashboards from metrics data."""

    def __init__(self, metrics_data: pd.DataFrame):
        """
        Initialize dashboard generator with metrics data.

        Args:
            metrics_data: DataFrame containing profiling metrics
        """
        self.df = metrics_data
        self.figures: List[go.Figure] = []

    def create_latency_overview(self) -> go.Figure:
        """Create latency overview chart."""
        # Aggregate per layer
        latency_by_layer = self.df.groupby('layer_name').agg({
            'forward_latency_ms': ['mean', 'std', 'min', 'max'],
            'p50_latency_ms': 'mean',
            'p95_latency_ms': 'mean',
            'p99_latency_ms': 'mean',
        }).round(2)

        # Sort by mean latency
        latency_by_layer = latency_by_layer.sort_values(
            ('forward_latency_ms', 'mean'),
            ascending=False
        )

        fig = go.Figure()
        fig.add_trace(go.Bar(
            name='Mean Latency',
            x=latency_by_layer.index,
            y=latency_by_layer[('forward_latency_ms', 'mean')],
            error_y=dict(
                type='data',
                array=latency_by_layer[('forward_latency_ms', 'std')],
                visible=True
            )
        ))

        fig.update_layout(
            title='Layer Latency Overview',
            xaxis_title='Layer Name',
            yaxis_title='Latency (ms)',
            height=500,
            showlegend=True,
        )

        return fig

    def create_memory_timeline(self) -> go.Figure:
        """Create memory usage timeline."""
        # Filter out non-GPU runs if needed
        gpu_data = self.df[self.df['device'] != 'cpu'].copy()
        if len(gpu_data) == 0:
            gpu_data = self.df.copy()

        # Add cumulative count for timeline
        gpu_data['timeline_index'] = range(len(gpu_data))

        fig = go.Figure()
        fig.add_trace(go.Scatter(
            name='VRAM Usage',
            x=gpu_data['timeline_index'],
            y=gpu_data['peak_vram_after'] / (1024**3),  # Convert to GB
            mode='lines+markers',
            marker=dict(size=6),
            line=dict(width=2, color='#636EFA'),
        ))

        # Add layer annotations (only for peaks)
        max_vram_idx = gpu_data['peak_vram_after'].idxmax()
        max_vram_value = gpu_data.loc[max_vram_idx, 'peak_vram_after'] / (1024**3)
        max_vram_layer = gpu_data.loc[max_vram_idx, 'layer_name']

        fig.add_annotation(
            x=max_vram_idx,
            y=max_vram_value,
            text=f"Max VRAM<br>{max_vram_layer}",
            showarrow=True,
            arrowhead=2,
            ax=50,
            ay=-50,
        )

        fig.update_layout(
            title='VRAM Usage Timeline',
            xaxis_title='Layer Execution Order',
            yaxis_title='VRAM (GB)',
            height=400,
            hovermode='closest',
        )

        return fig

    def create_layer_summary_table(self) -> go.Figure:
        """Create detailed layer summary table."""
        summary = self.df.groupby('layer_name').agg({
            'forward_latency_ms': ['mean', 'std', 'max'],
            'num_parameters': 'first',
            'peak_vram_after': 'mean',
        }).round(2)

        # Flatten column names
        summary.columns = ['_'.join(col).strip() for col in summary.columns]

        # Create table
        fig = go.Figure(data=[go.Table(
            header=dict(
                values=list(summary.columns),
                fill_color='paleturquoise',
                align='left'
            ),
            cells=dict(
                values=[summary[col] for col in summary.columns],
                fill_color='lavender',
                align='left',
                format=".2f"
            )
        )])

        fig.update_layout(
            title='Layer Summary Statistics',
            height=600,
        )

        return fig

    def create_layer_type_comparison(self) -> go.Figure:
        """Create comparison of different layer types."""
        if 'layer_type' not in self.df.columns:
            return go.Figure()

        layer_type_summary = self.df.groupby('layer_type').agg({
            'forward_latency_ms': 'mean',
            'num_parameters': 'sum',
            'peak_vram_after': 'mean',
        }).reset_index()

        fig = make_subplots(
            rows=1,
            cols=2,
            subplot_titles=['Mean Latency by Layer Type', 'Parameter Count by Layer Type']
        )

        fig.add_trace(go.Bar(
            name='Latency',
            x=layer_type_summary['layer_type'],
            y=layer_type_summary['forward_latency_ms'],
            marker_color='crimson',
        ), row=1, col=1)

        fig.add_trace(go.Bar(
            name='Parameters',
            x=layer_type_summary['layer_type'],
            y=layer_type_summary['num_parameters'],
            marker_color='teal',
        ), row=1, col=2)

        fig.update_layout(
            title='Layer Type Comparison',
            height=500,
        )
        fig.update_xaxes(title_text="Layer Type", row=1, col=1)
        fig.update_yaxes(title_text="Mean Latency (ms)", row=1, col=1)
        fig.update_xaxes(title_text="Layer Type", row=1, col=2)
        fig.update_yaxes(title_text="Total Parameters", row=1, col=2)

        return fig

    def create_parameter_latency_scatter(self) -> go.Figure:
        """Create scatter plot of parameters vs latency."""
        # Take the first entry per layer
        layer_data = self.df.groupby('layer_name').first().reset_index()

        fig = go.Figure(data=go.Scatter(
            x=layer_data['num_parameters'],
            y=layer_data['forward_latency_ms'],
            mode='markers+text',
            text=layer_data['layer_name'],
            textposition='top center',
            textfont=dict(size=8),
            marker=dict(
                size=15,
                color=layer_data['forward_latency_ms'],
                colorscale='Viridis',
                showscale=True,
                line_width=1,
                line_color='DarkSlateGrey'
            ),
            hovertemplate=(
                '<b>%{text}</b><br>' +
                'Parameters: %{x}<br>' +
                'Latency: %{y:.2f}ms<br>' +
                '<extra></extra>'
            )
        ))

        fig.update_layout(
            title='Parameters vs Latency (per Layer)',
            xaxis_title='Number of Parameters',
            yaxis_title='Mean Latency (ms)',
            xaxis_type='log',
            height=600,
        )

        return fig

    def add_summary_text(self) -> str:
        """Generate HTML summary text."""
        total_layers = self.df['layer_name'].nunique()
        avg_latency = self.df['forward_latency_ms'].mean()
        total_latency = self.df['forward_latency_ms'].sum()
        max_vram = self.df['peak_vram_after'].max() / (1024**3)  # GB
        total_params = self.df.groupby('layer_name')['num_parameters'].first().sum()

        summary_html = f"""
        <div style='font-family: Arial, sans-serif; padding: 20px; background-color: #f0f0f0; border-radius: 10px;'>
            <h2>🚀 Profiling Summary</h2>
            <ul style='font-size: 16px; line-height: 1.8;'>
                <li><strong>Total Layers Profiled:</strong> {total_layers}</li>
                <li><strong>Total Parameters:</strong> {total_params:,.0f}</li>
                <li><strong>Average Layer Latency:</strong> {avg_latency:.2f} ms</li>
                <li><strong>Total Forward Pass Latency:</strong> {total_latency:.2f} ms</li>
                <li><strong>Peak VRAM Usage:</strong> {max_vram:.2f} GB</li>
            </ul>
        </div>
        """

        return summary_html

    def export_html(self, output_path: Path, include_all: bool = True):
        """
        Export complete HTML dashboard.

        Args:
            output_path: Output file path
            include_all: Include all available charts
        """
        # Generate all figures
        self.figures = []

        self.figures.append(self.create_latency_overview())
        self.figures.append(self.create_memory_timeline())
        self.figures.append(self.create_parameter_latency_scatter())
        self.figures.append(self.create_layer_type_comparison())
        if len(self.df) < 50:  # Table is unwieldy for many layers
            self.figures.append(self.create_layer_summary_table())

        # Generate HTML
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>NoodleCore Observability Dashboard</title>
            <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    padding: 20px;
                    background-color: #ffffff;
                }}
                h1 {{
                    color: #2c3e50;
                    border-bottom: 3px solid #3498db;
                    padding-bottom: 10px;
                }}
                .summary {{
                    margin: 20px 0;
                }}
                .chart-container {{
                    background: #f8f9fa;
                    border: 1px solid #e9ecef;
                    border-radius: 8px;
                    padding: 20px;
                    margin: 20px 0;
                }}
            </style>
        </head>
        <body>
            <h1>📊 NoodleCore Observability Dashboard</h1>
            <p>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
            {self.add_summary_text()}
        """

        for i, fig in enumerate(self.figures):
            html_content += f"""
            <div class="chart-container">
                {fig.to_html(include_plotlyjs=False, div_id=f'chart_{i}')}
            </div>
            """

        html_content += """
        </body>
        </html>
        """

        # Write to file
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_content)

    def export_json(self, output_path: Path):
        """Export raw metrics as JSON."""
        self.df.to_json(output_path, orient='records', indent=2)

    @classmethod
    def from_jsonl(cls, jsonl_path: Path) -> 'DashboardGenerator':
        """Load metrics from JSONL file."""
        data = []
        with open(jsonl_path, 'r') as f:
            for line in f:
                data.append(json.loads(line))

        df = pd.DataFrame(data)
        return cls(df)

    def get_bottleneck_analysis(self) -> Dict[str, Any]:
        """Identify performance bottlenecks."""
        total_latency = self.df['forward_latency_ms'].sum()

        # Top 10 slowest layers by percentage
        self.df['latency_pct'] = (self.df['forward_latency_ms'] / total_latency) * 100
        top_bottlenecks = self.df.nlargest(10, 'latency_pct')[
            ['layer_name', 'forward_latency_ms', 'latency_pct']
        ].to_dict('records')

        # Total latency
        total_forward_ms = self.df['forward_latency_ms'].sum()
        total_p95_ms = self.df['p95_latency_ms'].sum()
        total_p99_ms = self.df['p99_latency_ms'].sum()

        return {
            'top_bottlenecks': top_bottlenecks,
            'total_latencies': {
                'mean_ms': total_forward_ms,
                'p95_ms': total_p95_ms,
                'p99_ms': total_p99_ms,
            },
            'memory_bottlenecks': self.df.nlargest(5, 'vram_increase')[
                ['layer_name', 'vram_increase']
            ].to_dict('records'),
        }
