import React from "react";
import { loadFonts } from "./fonts";

const { fontFamily } = loadFonts();

export const BookCover: React.FC<{
  scale?: number;
  authorName: string;
}> = ({ scale = 1, authorName }) => {
  return (
    <div
      style={{
        width: 640,
        height: 880,
        transform: `scale(${scale})`,
        backgroundColor: "#f6efdc",
        boxShadow: "0 40px 90px rgba(0,0,0,0.55), 0 0 0 1px rgba(212,175,106,0.4)",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: "70px 56px",
        textAlign: "center",
        position: "relative",
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: 18,
          border: "1px solid rgba(180,140,70,0.35)",
        }}
      />
      <div
        style={{
          fontFamily,
          fontWeight: 600,
          fontSize: 17,
          letterSpacing: 4,
          color: "#a9793a",
          textTransform: "uppercase",
        }}
      >
        Guía práctica para agentes inmobiliarios
      </div>
      <div
        style={{
          height: 1,
          width: 200,
          background: "#c8a25c",
          margin: "26px 0",
        }}
      />
      <div
        style={{
          fontFamily,
          fontWeight: 700,
          fontSize: 64,
          lineHeight: 1.05,
          color: "#241c10",
        }}
      >
        Kit Práctico
      </div>
      <div
        style={{
          fontFamily,
          fontWeight: 500,
          fontStyle: "italic",
          fontSize: 30,
          color: "#3a2e1b",
          marginTop: 10,
          lineHeight: 1.25,
        }}
      >
        para Agentes Inmobiliarios Nuevos
      </div>
      <div
        style={{
          fontFamily,
          fontSize: 19,
          color: "#5c4d31",
          marginTop: 26,
          lineHeight: 1.5,
          maxWidth: 440,
        }}
      >
        eBook práctico para captar, publicar, dar seguimiento y negociar
        propiedades con método
      </div>
      <div
        style={{
          height: 1,
          width: 200,
          background: "#c8a25c",
          margin: "30px 0 22px",
        }}
      />
      <div
        style={{
          fontFamily,
          fontSize: 15,
          letterSpacing: 3,
          color: "#a9793a",
          textTransform: "uppercase",
        }}
      >
        Por
      </div>
      <div
        style={{
          fontFamily,
          fontWeight: 700,
          fontSize: 26,
          color: "#241c10",
          marginTop: 6,
        }}
      >
        {authorName}
      </div>
      <div
        style={{
          fontFamily,
          fontStyle: "italic",
          fontSize: 18,
          color: "#5c4d31",
          marginTop: 2,
        }}
      >
        Empresaria Inmobiliaria
      </div>
    </div>
  );
};
