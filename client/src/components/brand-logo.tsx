import { useState } from "react";
import { ShieldCheck } from "lucide-react";
import { cn } from "@/lib/utils";

type BrandLogoProps = {
  variant?: "full" | "mark";
  className?: string;
};

export default function BrandLogo({ variant = "full", className }: BrandLogoProps) {
  const [hasError, setHasError] = useState(false);

  if (variant === "mark") {
    if (hasError) {
      return (
        <div className={cn("w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center text-white", className)}>
          <ShieldCheck className="w-5 h-5" />
        </div>
      );
    }

    return (
      <img
        src="/favicon.png"
        alt="Justice City mark"
        className={cn("h-8 w-8 rounded-lg object-cover", className)}
        onError={() => setHasError(true)}
      />
    );
  }

  if (hasError) {
    return (
      <span className={cn("font-display font-bold text-xl tracking-tight text-slate-900", className)}>
        Justice City
      </span>
    );
  }

  return (
    <img
      src="/logo.png?v=20260215"
      alt="Justice City"
      className={cn("h-9 w-auto max-w-[220px] object-contain", className)}
      onError={() => setHasError(true)}
    />
  );
}
