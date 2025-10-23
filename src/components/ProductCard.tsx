import { ExternalLink, Star } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";

interface ProductCardProps {
  name: string;
  price: number;
  store: string;
  rating?: number;
  imageUrl?: string;
  productUrl?: string;
  description?: string;
  isLowest?: boolean;
}

export const ProductCard = ({
  name,
  price,
  store,
  rating,
  imageUrl,
  productUrl,
  description,
  isLowest,
}: ProductCardProps) => {
  return (
    <Card className="overflow-hidden transition-all hover:shadow-lg group">
      <CardContent className="p-0">
        <div className="relative aspect-square overflow-hidden bg-muted">
          {imageUrl && (
            <img
              src={imageUrl}
              alt={name}
              className="w-full h-full object-cover transition-transform group-hover:scale-105"
            />
          )}
          {isLowest && (
            <Badge className="absolute top-2 right-2 bg-success text-success-foreground">
              Best Deal
            </Badge>
          )}
        </div>
        
        <div className="p-4 space-y-3">
          <div>
            <h3 className="font-semibold text-base line-clamp-1">{name}</h3>
            {description && (
              <p className="text-xs text-muted-foreground line-clamp-2 mt-1">{description}</p>
            )}
          </div>

          <div className="flex items-center justify-between">
            <div>
              <p className="text-2xl font-bold text-primary">${price.toFixed(2)}</p>
              <p className="text-xs text-muted-foreground">{store}</p>
            </div>
            {rating && (
              <div className="flex items-center gap-1 bg-secondary px-2 py-1 rounded-full">
                <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                <span className="text-xs font-medium">{rating.toFixed(1)}</span>
              </div>
            )}
          </div>

          {productUrl && (
            <Button 
              className="w-full" 
              variant="default"
              asChild
            >
              <a href={productUrl} target="_blank" rel="noopener noreferrer">
                View Product
                <ExternalLink className="w-4 h-4 ml-2" />
              </a>
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
};
