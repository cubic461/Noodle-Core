# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
Camera Viewer met FPS display (File-based)
# Real-time opslag van camerafeed met FPS meting als beelden
# """

import cv2
import time
import numpy as np
import argparse
import os
import pathlib.Path
import typing.Optional

class CameraViewerFile:
        """Real-time camera viewer met FPS display (opslag als bestanden)"""

    #     def __init__(self, camera_id: int = 0, output_dir: str = "camera_output"):
    self.camera_id = camera_id
    self.output_dir = Path(output_dir)
    self.output_dir.mkdir(exist_ok = True)

    self.cap = None
    self.fps = 0
    self.frame_count = 0
    self.start_time = time.time()
    self.last_fps_update = time.time()
    self.fps_history = []
    self.max_history = 30

    #         # Maak subdirectories
    (self.output_dir / "frames").mkdir(exist_ok = True)
    (self.output_dir / "previews").mkdir(exist_ok = True)

    #     def initialize(self) -bool):
    #         """Initialiseer camera"""
    #         try:
    self.cap = cv2.VideoCapture(self.camera_id)
    #             if not self.cap.isOpened():
                    print(f"Fout: Kon camera met ID {self.camera_id} niet openen")
    #                 return False

    #             # Get camera properties
    width = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = self.cap.get(cv2.CAP_PROP_FPS)

                print(f"Camera {self.camera_id} succesvol geïnitialiseerd")
                print(f"Resolutie: {width}x{height}")
                print(f"Camera FPS: {fps:.1f}")
                print(f"Output directory: {self.output_dir}")

    #             return True

    #         except Exception as e:
                print(f"Fout bij initialiseren camera: {e}")
    #             return False

    #     def calculate_fps(self) -float):
    #         """Bereken FPS op basis van recente frames"""
    current_time = time.time()

    #         # Update FPS elke seconde
    #         if current_time - self.last_fps_update >= 1.0:
    #             if self.frame_count 0):
    self.fps = self.frame_count / (current_time - self.last_fps_update)
                    self.fps_history.append(self.fps)

    #                 # Beperk geschiedenis
    #                 if len(self.fps_history) self.max_history):
                        self.fps_history.pop(0)

    self.frame_count = 0
    self.last_fps_update = current_time

    self.frame_count + = 1

    #         # Geef gemiddelde FPS van recente geschiedenis terug
    #         if self.fps_history:
                return sum(self.fps_history) / len(self.fps_history)
    #         return 0.0

    #     def draw_overlay(self, frame: np.ndarray) -np.ndarray):
    #         """Teken overlay informatie op frame"""
    #         # Maak kopie van frame
    result = frame.copy()

    #         # Bereken FPS
    current_fps = self.calculate_fps()

    #         # Tekst instellingen
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 0.7
    thickness = 2
    color = (0, 255, 0)  # Groen
    bg_color = (0, 0, 0)  # Zwart

    #         # FPS tekst
    fps_text = f"FPS: {current_fps:.1f}"
    fps_size = cv2.getTextSize(fps_text, font, font_scale, thickness)[0]
    fps_x = 10
    fps_y = fps_size[1] + 10

    #         # Tekst achtergrond
            cv2.rectangle(result, (fps_x-5, fps_y-fps_size[1]-5),
                         (fps_x+fps_size[0]+5, fps_y+5), bg_color, -1)

    #         # FPS tekst
            cv2.putText(result, fps_text, (fps_x, fps_y), font,
    #                    font_scale, color, thickness, cv2.LINE_AA)

    #         # Camera ID
    cam_text = f"Camera: {self.camera_id}"
    cam_size = cv2.getTextSize(cam_text, font, font_scale, thickness)[0]
    cam_y = fps_y + fps_size[1] + 15

    #         # Camera ID achtergrond
            cv2.rectangle(result, (fps_x-5, cam_y-cam_size[1]-5),
                         (fps_x+cam_size[0]+5, cam_y+5), bg_color, -1)

    #         # Camera ID tekst
            cv2.putText(result, cam_text, (fps_x, cam_y), font,
    #                    font_scale, color, thickness, cv2.LINE_AA)

    #         # Resolutie
    height, width = frame.shape[:2]
    res_text = f"Res: {width}x{height}"
    res_size = cv2.getTextSize(res_text, font, font_scale, thickness)[0]
    res_y = cam_y + cam_size[1] + 15

    #         # Resolutie achtergrond
            cv2.rectangle(result, (fps_x-5, res_y-res_size[1]-5),
                         (fps_x+res_size[0]+5, res_y+5), bg_color, -1)

    #         # Resolutie tekst
            cv2.putText(result, res_text, (fps_x, res_y), font,
    #                    font_scale, color, thickness, cv2.LINE_AA)

    #         # Frame counter
    counter_text = f"Frame: {self.frame_count}"
    counter_size = cv2.getTextSize(counter_text, font, font_scale, thickness)[0]
    counter_y = res_y + res_size[1] + 15

    #         # Frame counter achtergrond
            cv2.rectangle(result, (fps_x-5, counter_y-counter_size[1]-5),
                         (fps_x+counter_size[0]+5, counter_y+5), bg_color, -1)

    #         # Frame counter tekst
            cv2.putText(result, counter_text, (fps_x, counter_y), font,
    #                    font_scale, color, thickness, cv2.LINE_AA)

    #         return result

    #     def save_frame(self, frame: np.ndarray, frame_number: int) -None):
    #         """Sla frame op met overlay"""
    #         # Teken overlay
    overlay_frame = self.draw_overlay(frame)

    #         # Sla volledige frame op
    frame_path = self.output_dir / "frames" / f"frame_{frame_number:06d}.jpg"
            cv2.imwrite(str(frame_path), overlay_frame)

    #         # Sla kleine preview op
    preview = cv2.resize(overlay_frame, (320, 240))
    preview_path = self.output_dir / "previews" / f"preview_{frame_number:06d}.jpg"
            cv2.imwrite(str(preview_path), preview)

    #     def run(self, max_frames: int = 300, save_interval: int = 5) -None):
    #         """Start camera viewer"""
    #         if not self.initialize():
    #             return

            print(f"\nStart camera capture...")
            print(f"Max frames: {max_frames}")
            print(f"Save interval: {save_interval} frames")
            print(f"Druk op Ctrl+C om te stoppen")

    #         try:
    frame_number = 0
    last_save_frame = 0

    #             while frame_number < max_frames:
    #                 # Lees frame
    ret, frame = self.cap.read()
    #                 if not ret:
                        print("Kan frame niet lezen. Sluiten...")
    #                     break

    frame_number + = 1

    #                 # Sla frame op op interval
    #                 if frame_number - last_save_frame >= save_interval:
                        self.save_frame(frame, frame_number)
    last_save_frame = frame_number

                        # Toon status (minder vaak voor minder console overhead)
    #                     if frame_number % 10 = 0:
    current_time = time.time()
    elapsed = current_time - self.start_time
    #                         if self.fps_history:
    avg_fps = math.divide(sum(self.fps_history), len(self.fps_history))
                                print(f"\rFrame {frame_number}/{max_frames} | "
    #                                   f"FPS: {avg_fps:.1f} | "
    f"Elapsed: {elapsed:.1f}s", end = "")

    #                 # Kleinere vertraging voor hogere FPS
                    time.sleep(0.001)  # Verlaag van 0.01 naar 0.001

    #         except KeyboardInterrupt:
                print(f"\n\nAfgebroken door gebruiker")

    #         finally:
                self.cleanup()

    #     def cleanup(self) -None):
    #         """Maak op"""
    #         if self.cap:
                self.cap.release()

    #         # Toon finale statistieken
    #         if self.fps_history:
    avg_fps = math.divide(sum(self.fps_history), len(self.fps_history))
    min_fps = min(self.fps_history)
    max_fps = max(self.fps_history)

                print(f"\n\nStatistieken:")
                print(f"Gemiddelde FPS: {avg_fps:.1f}")
                print(f"Min FPS: {min_fps:.1f}")
                print(f"Max FPS: {max_fps:.1f}")
                print(f"Total frames: {self.frame_count}")

    #             # Tel opgeslagen bestanden
    frames_dir = self.output_dir / "frames"
    #             if frames_dir.exists():
    saved_frames = len(list(frames_dir.glob("*.jpg")))
                    print(f"Opgeslagen frames: {saved_frames}")

                print(f"\nBestanden opgeslagen in: {self.output_dir}")

function main()
    #     """Hoofdprogramma"""
    parser = argparse.ArgumentParser(description="NoodleVision Camera Viewer (File-based)")
    parser.add_argument("--camera", type = int, default=0,
    help = "Camera ID (standaard: 0)")
    parser.add_argument("--output-dir", type = str, default="camera_output",
    help = "Output directory (standaard: camera_output)")
    parser.add_argument("--max-frames", type = int, default=300,
    help = "Aantal frames om op te nemen (standaard: 300)")
    parser.add_argument("--save-interval", type = int, default=5,
    help = "Sla elke N frames op (standaard: 5)")

    args = parser.parse_args()

    #     # Maak viewer
    viewer = CameraViewerFile(
    camera_id = args.camera,
    output_dir = args.output_dir
    #     )

    #     # Start viewer
        viewer.run(
    max_frames = args.max_frames,
    save_interval = args.save_interval
    #     )

if __name__ == "__main__"
        main()
