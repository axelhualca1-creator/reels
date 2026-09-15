import React from "react";
import {
  AbsoluteFill,
  Audio,
  interpolate,
  Sequence,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { loadFonts } from "./fonts";

const { fontFamily } = loadFonts();

const ITEMS = [
  "Cómo conseguir tus primeras captaciones",
  "Qué documentos pedir antes de publicar",
  "Cómo crear una publicación que sí venda",
  "Seguimiento sin parecer insistente",
  "Cómo negociar una oferta con seguridad",
  "+ plantillas editables listas para usar",
];

const Item: React.FC<{ text: string; delay: number }> = ({ text, delay }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame: frame - delay, fps, config: { damping: 200 } });
  const opacity = interpolate(progress, [0, 1], [0, 1]);
  const x = interpolate(progress, [0, 1], [36, 0]);

  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 18,
        opacity,
        transform: `translateX(${x}px)`,
        marginBottom: 32,
      }}
    >
      <Sequence from={delay} durationInFrames={10}>
        <Audio src={staticFile("audio/tick.mp3")} volume={0.45} />
      </Sequence>
      <div
        style={{
          width: 40,
          height: 40,
          borderRadius: "50%",
          background: "linear-gradient(135deg, #e7c589, #b8894a)",
          color: "#241c10",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontWeight: 700,
          fontSize: 20,
          flexShrink: 0,
        }}
      >
        ✓
      </div>
      <div
        style={{
          fontFamily,
          fontWeight: 600,
          fontSize: 31,
          color: "#f5ead3",
          lineHeight: 1.2,
        }}
      >
        {text}
      </div>
    </div>
  );
};

export const ContentsScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const headerProgress = spring({ frame, fps, config: { damping: 200 } });

  return (
    <AbsoluteFill style={{ backgroundColor: "#0c0906", padding: "0 78px", justifyContent: "center" }}>
      <div
        style={{
          fontFamily,
          fontWeight: 700,
          fontSize: 26,
          letterSpacing: 3,
          textTransform: "uppercase",
          color: "#d4af6a",
          marginBottom: 40,
          opacity: interpolate(headerProgress, [0, 1], [0, 1]),
        }}
      >
        Lo que vas a encontrar dentro
      </div>
      {ITEMS.map((item, i) => (
        <Item key={item} text={item} delay={10 + i * 16} />
      ))}
    </AbsoluteFill>
  );
};
